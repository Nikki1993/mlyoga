//
//  FrameHandler.swift
//  mlyoga
//
//  Created by Nick Kononov on 18.12.2024.
//

import AVFoundation
import CoreImage
import Foundation
import Vision

class FrameHandler: NSObject, ObservableObject {
    @Published var frame: CGImage?
    @Published var parts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]

    private var permissionGranted: Bool = true
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()

    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                permissionGranted = true
            case .notDetermined:
                requestPermission()
            default:
                permissionGranted = false
        }
    }

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }

    func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        guard permissionGranted else { return print("permission not granted") }

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return print("no camera")
        }
        do {
            try videoDevice.lockForConfiguration()
        } catch {
            print("could not lock device for configuration")
            return
        }

        videoDevice.videoZoomFactor = 1
        videoDevice.unlockForConfiguration()

        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return print("no videoDeviceInput") }
        guard captureSession.canAddInput(videoDeviceInput) else { return print("could not add input") }

        captureSession.sessionPreset = .iFrame960x540
        captureSession.addInput(videoDeviceInput)

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)

        guard let connection = videoOutput.connection(with: .video) else { return print("no connection to videoOutput ") }

        if connection.isVideoRotationAngleSupported(90) {
            // Set the video capture's orientation to match that of the device.
            connection.videoRotationAngle = 90
        }

        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = true
        }

        if connection.isVideoStabilizationSupported {
            if connection.activeVideoStabilizationMode == .off {
                connection.preferredVideoStabilizationMode = .standard
            }
        }
    }
}

func process(_ image: CGImage) -> [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] {
    let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    let requestHandler = VNImageRequestHandler(cgImage: image,
                                               orientation: .upMirrored,
                                               options: [:])
    do {
        try requestHandler.perform([bodyPoseRequest])
    } catch {
        print("Can't make the request due to \(error)")
        return [:]
    }

    guard let results = bodyPoseRequest.results else {
        return [:]
    }

    guard let bodyParts = try? results.first?.recognizedPoints(.all) else {
        return [:]
    }

    return bodyParts
}

extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }

        let points = process(cgImage)
        // UI Updates (convert to async/await)
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
            self.parts = points
        }
    }

    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }

        return cgImage
    }
}

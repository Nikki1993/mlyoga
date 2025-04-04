//
//  FrameView.swift
//  mlyoga
//
//  Created by Nick Kononov on 18.12.2024.
//

import SwiftUI
import Vision

struct FrameView: View {
    var image: CGImage?
    var parts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]
    private let label = Text("frame")

    var body: some View {
        if let image = image {
            ZStack {
                Image(image, scale: 1.0, orientation: .up, label: label)
                PoseEstimatorView(
                    parts: parts,
                    size: CGSize(width: image.width, height: image.height)
                )
            }

        } else {
            Color.blue
        }
    }
}

#Preview {
    FrameView()
}

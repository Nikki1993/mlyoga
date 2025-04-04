//
//  PoseEsitmatorView.swift
//  mlyoga
//
//  Created by Nick Kononov on 18.12.2024.
//

import SwiftUI
import Vision

struct Stick: Shape {
    var points: [CGPoint]
    var size: CGSize
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if points.isEmpty { return path }

        path.move(to: points[0])
        for point in points {
            path.addLine(to: point)
        }

        return path.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))
            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height))
    }
}

typealias BodyParts = [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]

func getRightLeg(parts: BodyParts) -> [CGPoint] {
    guard let p1 = parts[.rightAnkle]?.location else { return [] }
    guard let p2 = parts[.rightKnee]?.location else { return [] }
    guard let p3 = parts[.rightHip]?.location else { return [] }
    guard let p4 = parts[.root]?.location else { return [] }

    return [p1, p2, p3, p4]
}

func getLeftLeg(parts: BodyParts) -> [CGPoint] {
    guard let p1 = parts[.leftAnkle]?.location else { return [] }
    guard let p2 = parts[.leftKnee]?.location else { return [] }
    guard let p3 = parts[.leftHip]?.location else { return [] }
    guard let p4 = parts[.root]?.location else { return [] }

    return [p1, p2, p3, p4]
}

func getRightArm(parts: BodyParts) -> [CGPoint] {
    guard let p1 = parts[.rightWrist]?.location else { return [] }
    guard let p2 = parts[.rightElbow]?.location else { return [] }
    guard let p3 = parts[.rightShoulder]?.location else { return [] }
    guard let p4 = parts[.neck]?.location else { return [] }

    return [p1, p2, p3, p4]
}

func getLeftArm(parts: BodyParts) -> [CGPoint] {
    guard let p1 = parts[.leftWrist]?.location else { return [] }
    guard let p2 = parts[.leftElbow]?.location else { return [] }
    guard let p3 = parts[.leftShoulder]?.location else { return [] }
    guard let p4 = parts[.neck]?.location else { return [] }

    return [p1, p2, p3, p4]
}

func getRootToNose(parts: BodyParts) -> [CGPoint] {
    guard let p1 = parts[.root]?.location else { return [] }
    guard let p2 = parts[.neck]?.location else { return [] }
    guard let p3 = parts[.nose]?.location else { return [] }

    return [p1, p2, p3]
}

struct PoseEstimatorView: View {
    var parts: BodyParts = [:]
    var size: CGSize = .zero

    var body: some View {
//        ZStack {
//            // Right leg
//            Stick(points: [poseEstimator.bodyParts[.rightAnkle]!.location, poseEstimator.bodyParts[.rightKnee]!.location, poseEstimator.bodyParts[.rightHip]!.location,
//                           poseEstimator.bodyParts[.root]!.location], size: size)
//            .stroke(lineWidth: 5.0)
//            .fill(Color.green)
//            // Left leg
//            Stick(points: [poseEstimator.bodyParts[.leftAnkle]!.location, poseEstimator.bodyParts[.leftKnee]!.location, poseEstimator.bodyParts[.leftHip]!.location,
//                           poseEstimator.bodyParts[.root]!.location], size: size)
//            .stroke(lineWidth: 5.0)
//            .fill(Color.green)
//            // Right arm
//            Stick(points: [poseEstimator.bodyParts[.rightWrist]!.location, poseEstimator.bodyParts[.rightElbow]!.location, poseEstimator.bodyParts[.rightShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size)
//                .stroke(lineWidth: 5.0)
//                .fill(Color.green)
//            // Left arm
//            Stick(points: [poseEstimator.bodyParts[.leftWrist]!.location, poseEstimator.bodyParts[.leftElbow]!.location, poseEstimator.bodyParts[.leftShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size)
//                .stroke(lineWidth: 5.0)
//                .fill(Color.green)
//            // Root to nose
//            Stick(points: [poseEstimator.bodyParts[.root]!.location,
//                           poseEstimator.bodyParts[.neck]!.location,  poseEstimator.bodyParts[.nose]!.location], size: size)
//            .stroke(lineWidth: 5.0)
//            .fill(Color.green)
//
//        }
        ZStack {
            Stick(
                points: getRightLeg(parts: parts),
                size: size
            )
            .stroke(lineWidth: 5.0)
            .fill(Color.green)

            Stick(
                points: getLeftLeg(parts: parts),
                size: size
            )
            .stroke(lineWidth: 5.0)
            .fill(Color.green)

            Stick(
                points: getRightArm(parts: parts),
                size: size
            )
            .stroke(lineWidth: 5.0)
            .fill(Color.green)

            Stick(
                points: getLeftArm(parts: parts),
                size: size
            )
            .stroke(lineWidth: 5.0)
            .fill(Color.green)

            Stick(
                points: getRootToNose(parts: parts),
                size: size
            )
            .stroke(lineWidth: 5.0)
            .fill(Color.green)
        }
    }
}

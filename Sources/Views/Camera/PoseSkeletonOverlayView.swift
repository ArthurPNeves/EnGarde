import SwiftUI
import Vision

struct PoseSkeletonOverlayView: View {
    struct Segment: Identifiable {
        let id: String
        let from: VNHumanBodyPoseObservation.JointName
        let to: VNHumanBodyPoseObservation.JointName
        let color: Color
    }

    let points: [VNHumanBodyPoseObservation.JointName: CGPoint]
    let segments: [Segment]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(segments) { segment in
                    if let start = points[segment.from], let end = points[segment.to] {
                        Path { path in
                            path.move(to: mappedPoint(start, in: proxy.size))
                            path.addLine(to: mappedPoint(end, in: proxy.size))
                        }
                        .stroke(segment.color, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                        .shadow(color: segment.color.opacity(0.45), radius: 3)
                    }
                }
            }
        }
    }

    private func mappedPoint(_ normalized: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: normalized.x * size.width, y: (1 - normalized.y) * size.height)
    }
}

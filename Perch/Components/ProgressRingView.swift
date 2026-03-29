import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let primaryColor: Color
    let backgroundColor: Color

    init(
        progress: Double,
        lineWidth: CGFloat = 8,
        primaryColor: Color = Theme.forestGreen,
        backgroundColor: Color = Theme.surface
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    primaryColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }
}

#Preview {
    ProgressRingView(progress: 0.65)
        .frame(width: 100, height: 100)
        .padding()
}

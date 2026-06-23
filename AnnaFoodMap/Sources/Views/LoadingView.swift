import SwiftUI

struct LoadingView: View {
    @State private var isPulsing = false
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Theme.headerGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 4)
                        .frame(width: 84, height: 84)

                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 84, height: 84)
                        .rotationEffect(.degrees(rotation))

                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                        .scaleEffect(isPulsing ? 1.08 : 0.92)
                }

                VStack(spacing: 4) {
                    Text("Anna Food Map")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("Low FODMAP Guide")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    LoadingView()
}

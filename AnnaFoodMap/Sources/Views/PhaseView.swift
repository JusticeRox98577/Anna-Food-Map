import SwiftUI
import Foundation

struct PhaseView: View {
    @AppStorage("fodmap.currentPhase") private var currentPhaseRaw: Int = 0
    @AppStorage("fodmap.phaseStart") private var phaseStartInterval: Double = Date().timeIntervalSince1970

    private var currentPhase: Phase { Phase(rawValue: currentPhaseRaw) ?? .elimination }

    private var dayInPhase: Int {
        let start = Date(timeIntervalSince1970: phaseStartInterval)
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: start), to: Calendar.current.startOfDay(for: Date())).day ?? 0
        return max(1, days + 1)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                progressStepper
                    .cardStyle()

                phaseDetailCard
                    .cardStyle()

                dayCounterCard
                    .cardStyle()

                advanceCard
                    .cardStyle()
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationTitle("Phase Tracker")
    }

    private var progressStepper: some View {
        HStack(spacing: 0) {
            ForEach(Phase.allCases) { phase in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(stepColor(for: phase))
                            .frame(width: 36, height: 36)
                        if phase.rawValue < currentPhase.rawValue {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(phase.rawValue + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(phase == currentPhase ? Theme.green600 : Theme.green600.opacity(0.6))
                        }
                    }
                    .overlay(
                        Circle().stroke(phase == currentPhase ? Theme.green500 : .clear, lineWidth: 2)
                            .frame(width: 44, height: 44)
                    )

                    Text(phase.name)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(phase == currentPhase ? Theme.green700 : Theme.ink500)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                if phase != Phase.allCases.last {
                    Rectangle()
                        .fill(phase.rawValue < currentPhase.rawValue ? Theme.green400 : Theme.green100)
                        .frame(height: 3)
                        .offset(y: -16)
                }
            }
        }
    }

    private func stepColor(for phase: Phase) -> Color {
        if phase.rawValue < currentPhase.rawValue { return Theme.green500 }
        if phase == currentPhase { return Theme.paper }
        return Theme.green100
    }

    private var phaseDetailCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(currentPhase.name + " Phase", systemImage: currentPhase.symbolName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.green800)

            Text(currentPhase.summary)
                .font(.system(size: 14))
                .foregroundStyle(Theme.ink700)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(currentPhase.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•").foregroundStyle(Theme.green600)
                        Text(tip)
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.ink700)
                    }
                }
            }
            .padding(.top, 4)
        }
    }

    private var dayCounterCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(dayInPhase)")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(Theme.green700)
                Text("in this phase")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.ink500)
            }
            Spacer()
            Button {
                phaseStartInterval = Date().timeIntervalSince1970
            } label: {
                Label("Reset day counter", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .semibold))
            }
            .buttonStyle(.bordered)
            .tint(Theme.green600)
        }
    }

    private var advanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Move to next phase")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.green800)
            Text("Only advance when you and your care provider feel ready.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.ink500)

            HStack(spacing: 10) {
                Button {
                    if let prev = currentPhase.previous {
                        currentPhaseRaw = prev.rawValue
                        phaseStartInterval = Date().timeIntervalSince1970
                    }
                } label: {
                    Label("Previous", systemImage: "arrow.left")
                }
                .buttonStyle(.bordered)
                .tint(Theme.green600)
                .disabled(currentPhase.previous == nil)

                Button {
                    if let next = currentPhase.next {
                        currentPhaseRaw = next.rawValue
                        phaseStartInterval = Date().timeIntervalSince1970
                    }
                } label: {
                    Label(currentPhase.next == nil ? "Final Phase" : "Next Phase", systemImage: "arrow.right")
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.green600)
                .disabled(currentPhase.next == nil)
            }
        }
    }
}

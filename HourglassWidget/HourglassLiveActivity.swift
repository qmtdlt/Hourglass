import ActivityKit
import SwiftUI
import WidgetKit

struct HourglassLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HourglassActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color(red: 0.08, green: 0.08, blue: 0.12))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    PhaseBadge(phase: context.state.phase)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    TimerText(state: context.state, font: .system(size: 28, weight: .semibold, design: .monospaced))
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedStatusView(state: context.state)
                }
            } compactLeading: {
                Text(context.state.phase.shortLabel)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(context.state.phase.tintColor)
            } compactTrailing: {
                CompactTrailingView(state: context.state)
            } minimal: {
                Image(systemName: "hourglass")
                    .foregroundStyle(context.state.phase.tintColor)
            }
            .keylineTint(context.state.phase.tintColor)
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<HourglassActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                PhaseBadge(phase: context.state.phase)
                Spacer()
                StatusCaption(state: context.state)
            }

            TimerText(
                state: context.state,
                font: .system(size: 40, weight: .thin, design: .monospaced)
            )

            Text(context.state.statusMessage)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

private struct ExpandedStatusView: View {
    let state: HourglassActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(state.phase.displayTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            Text(state.statusMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CompactTrailingView: View {
    let state: HourglassActivityAttributes.ContentState

    var body: some View {
        Group {
            switch state.mode {
            case .running:
                if let endDate = state.phaseEndDate {
                    Text(endDate, style: .timer)
                } else {
                    Text("--:--")
                }
            case .paused:
                Text(durationString(state.pausedRemainingTime))
            case .needsFlip:
                Text("翻转")
            }
        }
        .font(.system(size: 13, weight: .semibold, design: .monospaced))
        .foregroundStyle(.white)
        .monospacedDigit()
    }
}

private struct TimerText: View {
    let state: HourglassActivityAttributes.ContentState
    let font: Font

    var body: some View {
        Group {
            switch state.mode {
            case .running:
                if let endDate = state.phaseEndDate {
                    Text(endDate, style: .timer)
                } else {
                    Text("--:--")
                }
            case .paused:
                Text(durationString(state.pausedRemainingTime))
            case .needsFlip:
                Text("00:00")
            }
        }
        .font(font)
        .foregroundStyle(.white)
        .monospacedDigit()
    }
}

private struct PhaseBadge: View {
    let phase: HourglassActivityAttributes.Phase

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(phase.tintColor)
                .frame(width: 8, height: 8)

            Text(phase.displayTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

private struct StatusCaption: View {
    let state: HourglassActivityAttributes.ContentState

    var body: some View {
        Text(state.shortStatus)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.6))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.08), in: Capsule())
    }
}

private extension HourglassActivityAttributes.Phase {
    var displayTitle: String {
        switch self {
        case .sitting:
            return "坐姿"
        case .standing:
            return "站立"
        }
    }

    var shortLabel: String {
        switch self {
        case .sitting:
            return "坐"
        case .standing:
            return "站"
        }
    }

    var tintColor: Color {
        switch self {
        case .sitting:
            return Color(red: 0.40, green: 0.70, blue: 1.00)
        case .standing:
            return Color(red: 0.50, green: 0.90, blue: 0.60)
        }
    }
}

private extension HourglassActivityAttributes.ContentState {
    var shortStatus: String {
        switch mode {
        case .running:
            return "进行中"
        case .paused:
            return "已暂停"
        case .needsFlip:
            return "等待翻转"
        }
    }

    var statusMessage: String {
        switch mode {
        case .running:
            return "\(phase.displayTitle)进行中"
        case .paused:
            return "已暂停，回到 App 继续"
        case .needsFlip:
            return "翻转手机开始下一阶段"
        }
    }
}

private func durationString(_ timeInterval: TimeInterval?) -> String {
    let totalSeconds = max(0, Int((timeInterval ?? 0).rounded()))
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    return String(format: "%02d:%02d", minutes, seconds)
}

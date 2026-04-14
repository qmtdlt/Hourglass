import SwiftUI

struct HistoryView: View {
    @StateObject private var vm = HistoryViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()

    private let accentColor = Color(red: 0.5, green: 0.4, blue: 0.9)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.12).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .colorScheme(.dark)
                            .padding(.horizontal)

                        dailySummaryCard

                        sessionsList
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundColor(accentColor)
                }
            }
            .onAppear { vm.load() }
            .onChange(of: selectedDate) { vm.load() }
        }
        .preferredColorScheme(.dark)
    }

    private var dailySummaryCard: some View {
        VStack(spacing: 16) {
            Text(dateTitle(selectedDate))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1)

            HStack(spacing: 24) {
                statItem(
                    icon: "figure.seated.seatbelt",
                    label: "坐姿",
                    value: formatDuration(vm.totalSittingTime(for: selectedDate)),
                    color: Color(red: 0.4, green: 0.7, blue: 1.0)
                )
                Divider().frame(height: 40).background(Color.white.opacity(0.1))
                statItem(
                    icon: "figure.stand",
                    label: "站立",
                    value: formatDuration(vm.totalStandingTime(for: selectedDate)),
                    color: Color(red: 0.5, green: 0.9, blue: 0.6)
                )
                Divider().frame(height: 40).background(Color.white.opacity(0.1))
                statItem(
                    icon: "arrow.2.circlepath",
                    label: "循环",
                    value: "\(vm.completedCycles(for: selectedDate))",
                    color: accentColor
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var sessionsList: some View {
        let sessions = vm.sessionsForDate(selectedDate)
        return VStack(spacing: 10) {
            if sessions.isEmpty {
                Text("暂无记录")
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.top, 40)
            } else {
                ForEach(sessions) { session in
                    SessionRowView(session: session)
                }
            }
        }
        .padding(.horizontal)
    }

    private func statItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private func dateTitle(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "今天" }
        if Calendar.current.isDateInYesterday(date) { return "昨天" }
        let fmt = DateFormatter()
        fmt.dateFormat = "M月d日"
        return fmt.string(from: date)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

struct SessionRowView: View {
    let session: CycleSession

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(timeLabel(session.startedAt))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                Text("\(session.phases.count) 个阶段 · \(session.completedCycles) 次完整循环")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDuration(session.totalSittingTime + session.totalStandingTime))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func timeLabel(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

import SwiftUI

struct SettingsView: View {
    @Binding var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    private let durations: [TimeInterval] = [1 * 60, 5 * 60, 10 * 60, 15 * 60, 20 * 60, 25 * 60, 30 * 60, 45 * 60, 60 * 60]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.12).ignoresSafeArea()

                List {
                    Section {
                        durationPicker(title: "坐姿时长", value: $settings.sittingDuration)
                        durationPicker(title: "站立时长", value: $settings.standingDuration)
                    } header: {
                        sectionHeader("时长设置")
                    }

                    Section {
                        Toggle(isOn: $settings.soundEnabled) {
                            label("声音提示", icon: "speaker.wave.2.fill")
                        }
                        Toggle(isOn: $settings.hapticEnabled) {
                            label("震动反馈", icon: "iphone.radiowaves.left.and.right")
                        }
                    } header: {
                        sectionHeader("提示方式")
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.9))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func durationPicker(title: String, value: Binding<TimeInterval>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Picker("", selection: value) {
                ForEach(durations, id: \.self) { d in
                    Text(durationLabel(d)).tag(d)
                }
            }
            .pickerStyle(.menu)
            .tint(Color(red: 0.5, green: 0.4, blue: 0.9))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private func label(_ title: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.9))
                .frame(width: 20)
            Text(title).foregroundColor(.white)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.white.opacity(0.4))
            .textCase(nil)
    }

    private func durationLabel(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        return "\(minutes) 分钟"
    }
}

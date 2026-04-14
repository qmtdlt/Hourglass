import SwiftUI

struct MainTimerView: View {
    @ObservedObject var vm: TimerViewModel
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 16)

                Spacer()

                phaseLabel

                Spacer().frame(height: 24)

                Text("⏳")
                    .font(.system(size: 160))
                    .frame(width: 220, height: 300)
                    .scaleEffect(vm.state == .running ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: vm.state == .running)

                Spacer().frame(height: 32)

                countdownLabel

                Spacer().frame(height: 40)

                controlButtons

                Spacer()

                if vm.state == .finished {
                    flipHint
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: $vm.settings)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .confirmationDialog("确认重置", isPresented: $showResetConfirm) {
            Button("重置计时器", role: .destructive) { vm.reset() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("当前进度将被记录为未完成")
        }
        .animation(.easeInOut(duration: 0.3), value: vm.state)
        .rotationEffect(.degrees(vm.rotationDegrees))
        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: vm.rotationDegrees)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }

    // MARK: - Components

    private var background: some View {
        Color.clear
    }

    private var topBar: some View {
        HStack {
            Button {
                showHistory = true
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Text("HOURGLASS")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .tracking(4)

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private var phaseLabel: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(vm.currentPhase == .sitting ? Color(red: 0.4, green: 0.7, blue: 1.0) : Color(red: 0.5, green: 0.9, blue: 0.6))
                .frame(width: 6, height: 6)
            Text(vm.currentPhase.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .tracking(2)
        }
        .opacity(vm.state == .idle ? 0 : 1)
    }

    private var countdownLabel: some View {
        Text(vm.state == .idle ? "--:--" : timeString(vm.remainingTime))
            .font(.system(size: 72, weight: .thin, design: .monospaced))
            .foregroundColor(.white)
            .monospacedDigit()
    }

    private var controlButtons: some View {
        HStack(spacing: 32) {
            if vm.state != .idle {
                Button {
                    showResetConfirm = true
                } label: {
                    controlIcon("arrow.counterclockwise")
                }
            }

            mainButton

            if vm.state == .running || vm.state == .paused || vm.state == .finished {
                Button {
                    vm.skipPhase()
                } label: {
                    controlIcon("forward.end.fill")
                }
            }
        }
    }

    private var mainButton: some View {
        Button {
            switch vm.state {
            case .idle:    vm.start()
            case .running: vm.pause()
            case .paused:  vm.resume()
            case .finished: break
            }
        } label: {
            ZStack {
                Circle()
                    .fill(mainButtonColor)
                    .frame(width: 72, height: 72)
                    .shadow(color: mainButtonColor.opacity(0.5), radius: 20)
                Image(systemName: mainButtonIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .disabled(vm.state == .finished)
    }

    private var mainButtonColor: Color {
        switch vm.state {
        case .idle:     return Color(red: 0.5, green: 0.4, blue: 0.9)
        case .running:  return Color(red: 0.9, green: 0.5, blue: 0.3)
        case .paused:   return Color(red: 0.3, green: 0.75, blue: 0.5)
        case .finished: return Color.gray.opacity(0.4)
        }
    }

    private var mainButtonIcon: String {
        switch vm.state {
        case .idle:     return "play.fill"
        case .running:  return "pause.fill"
        case .paused:   return "play.fill"
        case .finished: return "checkmark"
        }
    }

    private var flipHint: some View {
        VStack(spacing: 6) {
            Image(systemName: "arrow.up.and.down.circle")
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.5))
                .symbolEffect(.bounce, options: .repeating)
            Text("翻转手机开始下一阶段")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1)
        }
        .padding(.bottom, 32)
    }

    private func controlIcon(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 52, height: 52)
            Image(systemName: name)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private func timeString(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval))
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}

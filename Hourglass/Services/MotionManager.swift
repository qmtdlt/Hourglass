import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private var flipConfirmTimer: Timer?
    private var isCurrentlyFlipped = false
    private var pendingFlipSign: Int = 1

    // direction: +1 = 顺时针旋转180°, -1 = 逆时针旋转180°
    var onFlipDetected: ((_ direction: Int) -> Void)?

    private let updateInterval: TimeInterval = 0.05
    private let flipConfirmDuration: TimeInterval = 1.0

    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.handleMotion(motion)
        }
    }

    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        flipConfirmTimer?.invalidate()
        flipConfirmTimer = nil
        isCurrentlyFlipped = false
    }

    private func handleMotion(_ motion: CMDeviceMotion) {
        let gravity = motion.gravity
        let rate = motion.rotationRate

        // 用重力向量判断手机是否倒置
        let isInverted = gravity.y > 0.7 || gravity.z > 0.7
        let isNormal   = gravity.y < -0.7 || gravity.z < -0.7

        if isInverted && !isCurrentlyFlipped {
            // 正面 → 倒置：记录旋转方向并等待确认
            isCurrentlyFlipped = true
            pendingFlipSign = flipSign(from: rate, gravity: gravity)
            scheduleFlip()
        } else if isNormal && isCurrentlyFlipped {
            // 倒置 → 正面：记录旋转方向并等待确认
            isCurrentlyFlipped = false
            pendingFlipSign = flipSign(from: rate, gravity: gravity)
            scheduleFlip()
        } else if !isInverted && !isNormal {
            // 手机在旋转中途，更新方向采样（取最新的）
            let dominantRate = max(abs(rate.x), abs(rate.y), abs(rate.z))
            if dominantRate > 0.5 {
                pendingFlipSign = flipSign(from: rate, gravity: gravity)
            }
            // 不取消 timer，让手机继续翻转到位
        }
    }

    private func flipSign(from rate: CMRotationRate, gravity: CMAcceleration) -> Int {
        // 根据重力判断当前主要旋转轴，然后取该轴角速度的符号
        let ax = abs(gravity.x)
        let ay = abs(gravity.y)
        let az = abs(gravity.z)

        if az > ax && az > ay {
            // 手机平放，绕 x 或 y 轴翻转
            let dominant = abs(rate.x) >= abs(rate.y) ? rate.x : rate.y
            return dominant >= 0 ? -1 : 1
        } else {
            // 手机竖放，绕 x 轴翻转（前后翻）或 z 轴翻转（平面旋转）
            let dominant = abs(rate.x) >= abs(rate.z) ? rate.x : rate.z
            return dominant >= 0 ? -1 : 1
        }
    }

    private func scheduleFlip() {
        flipConfirmTimer?.invalidate()
        let sign = pendingFlipSign
        flipConfirmTimer = Timer.scheduledTimer(withTimeInterval: flipConfirmDuration, repeats: false) { [weak self] _ in
            self?.onFlipDetected?(sign)
        }
    }
}

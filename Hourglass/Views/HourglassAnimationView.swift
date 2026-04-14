import SwiftUI
import Lottie

// MARK: - Lottie wrapper (for future use when hourglass.json is available)

struct HourglassAnimationView: UIViewRepresentable {
    var isPlaying: Bool
    var progress: Double

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: "hourglass")
        view.contentMode = .scaleAspectFit
        view.backgroundBehavior = .pauseAndRestore
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.currentProgress = AnimationProgressTime(progress)
        if isPlaying {
            if !uiView.isAnimationPlaying { uiView.play() }
        } else {
            uiView.pause()
        }
    }
}

// MARK: - SF Symbols hourglass (active implementation)

struct HourglassPlaceholderView: View {
    var progress: Double   // 0 = sand all on top, 1 = sand all at bottom
    var isRunning: Bool
    var isFlipped: Bool = false

    // Symbol switches at 50% — top half filled → bottom half filled
    private var symbolName: String {
        progress < 0.5 ? "hourglass.tophalf.filled" : "hourglass.bottomhalf.filled"
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                // Glow ring while running
                if isRunning {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.65, blue: 0.30).opacity(0.18),
                                    .clear
                                ],
                                center: .center,
                                startRadius: size * 0.15,
                                endRadius: size * 0.52
                            )
                        )
                        .frame(width: size, height: size)
                }

                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.58)
                    .foregroundStyle(
                        Color(red: 0.95, green: 0.78, blue: 0.32),   // sand (primary)
                        Color.white.opacity(0.55)                      // glass (secondary)
                    )
                    .shadow(color: Color(red: 0.95, green: 0.78, blue: 0.32).opacity(0.35),
                            radius: 12, x: 0, y: 4)
                    // Pulse while running, bounce on symbol change
                    .symbolEffect(.pulse, isActive: isRunning)
                    .symbolEffect(.bounce, value: symbolName)
                    .animation(.easeInOut(duration: 0.4), value: symbolName)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Inner mask that matches the glass shell interior cavity

struct HourglassInnerMask: Shape {
    /// All proportions are fractions of the local frame (w x h) which is the glass frame.
    /// Glass shell proportions (fractions of image = fractions of this frame):
    ///   Top opening:      y≈0.06, half-width≈0.28
    ///   Top widest:       y≈0.24, half-width≈0.44
    ///   Neck:             y≈0.50, half-width≈0.12
    ///   Bottom widest:    y≈0.76, half-width≈0.44
    ///   Bottom opening:   y≈0.94, half-width≈0.28
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX

        // Key y positions
        let yTop    = h * 0.06
        let yTopW   = h * 0.24
        let yMid    = h * 0.50
        let yBotW   = h * 0.76
        let yBot    = h * 0.94

        // Half-widths at each key y
        let hwTop   = w * 0.28
        let hwTopW  = w * 0.44
        let hwMid   = w * 0.12
        let hwBotW  = w * 0.44
        let hwBot   = w * 0.28

        var path = Path()

        // Start at top-left opening corner
        path.move(to: CGPoint(x: cx - hwTop, y: yTop))

        // Top edge (flat arc across the top opening)
        path.addLine(to: CGPoint(x: cx + hwTop, y: yTop))

        // Right side: from top opening → top widest → neck → bottom widest → bottom opening
        // Top opening → top widest (curves outward)
        path.addCurve(
            to: CGPoint(x: cx + hwTopW, y: yTopW),
            control1: CGPoint(x: cx + hwTop + (hwTopW - hwTop) * 0.5, y: yTop + (yTopW - yTop) * 0.2),
            control2: CGPoint(x: cx + hwTopW, y: yTop + (yTopW - yTop) * 0.6)
        )
        // Top widest → neck (curves inward)
        path.addCurve(
            to: CGPoint(x: cx + hwMid, y: yMid),
            control1: CGPoint(x: cx + hwTopW, y: yTopW + (yMid - yTopW) * 0.5),
            control2: CGPoint(x: cx + hwMid + (hwTopW - hwMid) * 0.3, y: yMid - (yMid - yTopW) * 0.15)
        )
        // Neck → bottom widest (curves outward)
        path.addCurve(
            to: CGPoint(x: cx + hwBotW, y: yBotW),
            control1: CGPoint(x: cx + hwMid + (hwBotW - hwMid) * 0.3, y: yMid + (yBotW - yMid) * 0.15),
            control2: CGPoint(x: cx + hwBotW, y: yBotW - (yBotW - yMid) * 0.5)
        )
        // Bottom widest → bottom opening (curves inward)
        path.addCurve(
            to: CGPoint(x: cx + hwBot, y: yBot),
            control1: CGPoint(x: cx + hwBotW, y: yBotW + (yBot - yBotW) * 0.4),
            control2: CGPoint(x: cx + hwBot + (hwBotW - hwBot) * 0.5, y: yBot - (yBot - yBotW) * 0.2)
        )

        // Bottom edge (flat line across bottom opening)
        path.addLine(to: CGPoint(x: cx - hwBot, y: yBot))

        // Left side: mirror (bottom opening → bottom widest → neck → top widest → top opening)
        // Bottom opening → bottom widest (curves outward)
        path.addCurve(
            to: CGPoint(x: cx - hwBotW, y: yBotW),
            control1: CGPoint(x: cx - hwBot - (hwBotW - hwBot) * 0.5, y: yBot - (yBot - yBotW) * 0.2),
            control2: CGPoint(x: cx - hwBotW, y: yBotW + (yBot - yBotW) * 0.4)
        )
        // Bottom widest → neck (curves inward)
        path.addCurve(
            to: CGPoint(x: cx - hwMid, y: yMid),
            control1: CGPoint(x: cx - hwBotW, y: yBotW - (yBotW - yMid) * 0.5),
            control2: CGPoint(x: cx - hwMid - (hwBotW - hwMid) * 0.3, y: yMid + (yBotW - yMid) * 0.15)
        )
        // Neck → top widest (curves outward)
        path.addCurve(
            to: CGPoint(x: cx - hwTopW, y: yTopW),
            control1: CGPoint(x: cx - hwMid - (hwTopW - hwMid) * 0.3, y: yMid - (yMid - yTopW) * 0.15),
            control2: CGPoint(x: cx - hwTopW, y: yTopW + (yMid - yTopW) * 0.5)
        )
        // Top widest → top opening (curves inward)
        path.addCurve(
            to: CGPoint(x: cx - hwTop, y: yTop),
            control1: CGPoint(x: cx - hwTopW, y: yTop + (yTopW - yTop) * 0.6),
            control2: CGPoint(x: cx - hwTop - (hwTopW - hwTop) * 0.5, y: yTop + (yTopW - yTop) * 0.2)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Upper sand (sits at bottom of top chamber, level drops as progress increases)

struct UpperSandView: View {
    var progress: Double  // 0 = full top chamber, 1 = empty top chamber
    private let sandColor = Color(red: 0.85, green: 0.68, blue: 0.40)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // The top chamber occupies y: 0.06*h .. 0.50*h in the glass frame
            // Sand is anchored at the neck (y = 0.50*h = midY) and rises upward
            let topChamberTop  = h * 0.06
            let midY           = h * 0.50
            let topChamberH    = midY - topChamberTop
            let sandH          = topChamberH * max(0, 1.0 - progress)

            // Sand rectangle: from (midY - sandH) to midY
            let sandRect = CGRect(x: 0, y: midY - sandH, width: w, height: sandH)

            Rectangle()
                .fill(sandColor)
                .frame(width: sandRect.width, height: max(0, sandRect.height))
                .position(x: w * 0.5, y: sandRect.midY)
        }
    }
}

// MARK: - Lower sand (accumulates from bottom up, with a mound arc at the top surface)

struct LowerSandView: View {
    var progress: Double  // 0 = empty bottom chamber, 1 = full bottom chamber
    private let sandColor = Color(red: 0.85, green: 0.68, blue: 0.40)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // The bottom chamber occupies y: 0.50*h .. 0.94*h in the glass frame
            let midY           = h * 0.50
            let botChamberBot  = h * 0.94
            let botChamberH    = botChamberBot - midY
            let sandH          = botChamberH * min(1.0, max(0, progress))
            let sandTop        = botChamberBot - sandH
            let moundDepth     = min(sandH * 0.18, h * 0.04)  // subtle mound at the top surface

            if sandH > 0 {
                Canvas { ctx, size in
                    // Build a path: flat bottom at botChamberBot, sides up to sandTop,
                    // with a downward arc (mound) at the top surface
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: botChamberBot))
                    path.addLine(to: CGPoint(x: 0, y: sandTop))
                    // Arc mound: control point dips down by moundDepth
                    path.addQuadCurve(
                        to: CGPoint(x: w, y: sandTop),
                        control: CGPoint(x: w * 0.5, y: sandTop + moundDepth)
                    )
                    path.addLine(to: CGPoint(x: w, y: botChamberBot))
                    path.closeSubpath()

                    ctx.fill(path, with: .color(sandColor))
                }
                .frame(width: w, height: h)
            }
        }
    }
}

// MARK: - Falling particles at neck

struct FallingSandView: View {
    var isRunning: Bool
    var progress: Double
    private let sandColor = Color(red: 0.85, green: 0.68, blue: 0.40)

    var body: some View {
        if isRunning && progress > 0.02 && progress < 0.98 {
            TimelineView(.animation) { timeline in
                Canvas { ctx, size in
                    let w = size.width
                    let h = size.height
                    let t = timeline.date.timeIntervalSinceReferenceDate

                    // Neck center: x = w*0.50, y spans h*0.44 .. h*0.58 in the glass frame
                    let neckCenterX = w * 0.50
                    let neckTopY    = h * 0.44
                    let neckBotY    = h * 0.58
                    let neckSpan    = neckBotY - neckTopY

                    for i in 0..<6 {
                        let phase  = (t * 2.4 + Double(i) * (1.0 / 6.0)).truncatingRemainder(dividingBy: 1.0)
                        let py     = neckTopY + phase * neckSpan
                        let sway   = sin(t * 3.5 + Double(i) * 1.1) * (w * 0.018)
                        let px     = neckCenterX + sway
                        let alpha  = 0.55 + sin(phase * .pi) * 0.45
                        let radius = w * 0.018
                        ctx.fill(
                            Path(ellipseIn: CGRect(
                                x: px - radius, y: py - radius,
                                width: radius * 2, height: radius * 2
                            )),
                            with: .color(sandColor.opacity(alpha))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Composite sand layers, clipped to the glass inner mask

struct SandLayersView: View {
    var progress: Double
    var isRunning: Bool

    var body: some View {
        ZStack {
            UpperSandView(progress: progress)
            LowerSandView(progress: progress)
            FallingSandView(isRunning: isRunning, progress: progress)
        }
        .clipShape(HourglassInnerMask())
    }
}

// MARK: - Main hourglass body combining all layers

struct HourglassBody: View {
    var progress: Double
    var isRunning: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Layer 1 (bottom): bottom base
                Image("bottom_base_final")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: w * 0.90)
                    .position(x: w * 0.50, y: h * 0.91)

                // Layer 2: sand layers clipped to glass interior
                SandLayersView(progress: progress, isRunning: isRunning)
                    .frame(width: w, height: h * 0.74)
                    .position(x: w * 0.50, y: h * 0.50)

                // Layer 3: glass shell over sand
                Image("glass_shell_final")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: w, height: h * 0.74)
                    .position(x: w * 0.50, y: h * 0.50)

                // Layer 4: glass highlight reflection
                Image("glass_highlight_final")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: w * 0.62)
                    .position(x: w * 0.50, y: h * 0.17)

                // Layer 5 (top): top base
                Image("top_base_final")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: w * 0.90)
                    .position(x: w * 0.50, y: h * 0.09)
            }
        }
        .aspectRatio(0.65, contentMode: .fit)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.08, green: 0.08, blue: 0.12)
            .ignoresSafeArea()

        VStack(spacing: 32) {
            HStack(spacing: 24) {
                VStack {
                    Text("progress: 0")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.caption)
                    HourglassPlaceholderView(progress: 0.0, isRunning: false)
                        .frame(width: 140, height: 215)
                }
                VStack {
                    Text("progress: 0.5")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.caption)
                    HourglassPlaceholderView(progress: 0.5, isRunning: true)
                        .frame(width: 140, height: 215)
                }
                VStack {
                    Text("progress: 1")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.caption)
                    HourglassPlaceholderView(progress: 1.0, isRunning: false)
                        .frame(width: 140, height: 215)
                }
            }
        }
        .padding()
    }
}

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// 寵物主視覺區：負責顯示麻糬圖片、狀態特效與原生動畫
struct PetView: View {
    let imageName: String
    let lastAction: PetAction
    let interactionCount: Int
    let statusHint: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Ambient Animation States
    @State private var isAmbientActive: Bool = false

    // MARK: - Transient Interaction Animation States
    @State private var feedScale: CGFloat = 1.0
    @State private var playBounceY: CGFloat = 0.0
    @State private var petRotation: Double = 0.0
    @State private var showReactionBadge: Bool = false
    @State private var reactionTask: Task<Void, Never>?

    /// 是否處於睡眠視覺狀態
    private var isSleepingState: Bool {
        imageName == "mochi_sleeping" || lastAction == .sleeping
    }

    /// 對應當前互動的可愛小圖示
    private var reactionEmoji: String {
        switch lastAction {
        case .idle:
            return "✨"
        case .eating:
            return "🍙"
        case .playing:
            return "🎵"
        case .sleeping:
            return "💤"
        case .petting:
            return "💕"
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let availableSide = min(proxy.size.width, proxy.size.height)
            let petSize = min(max(availableSide * 0.78, 120), 195)
            let glowSize = min(max(availableSide * 0.92, 140), 225)

            ZStack {
                // 柔和背景光暈與舞台底座
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                stageGlowColor.opacity(0.32),
                                stageGlowColor.opacity(0.10),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: glowSize * 0.52
                        )
                    )
                    .frame(width: glowSize, height: glowSize)
                    .scaleEffect(isAmbientActive && !reduceMotion ? 1.04 : 0.96)

                // 角色腳下柔和陰影橢圓
                Ellipse()
                    .fill(AppTheme.textBrown.opacity(0.11))
                    .frame(width: petSize * 0.68, height: max(petSize * 0.10, 14))
                    .offset(y: petSize * 0.36)
                    .scaleEffect(
                        x: isAmbientActive && !reduceMotion && !isSleepingState ? 0.92 : 1.02,
                        y: 1.0
                    )

                // 麻糬本體（分層套用持續動畫與單次互動動畫，避免動畫衝突）
                petGraphic(size: petSize)
                    .id(imageName)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .scale(scale: 0.94))
                    )
                    // 單次互動動畫層（餵食縮放、玩耍彈跳、摸摸擺動）
                    .scaleEffect(feedScale)
                    .offset(y: playBounceY)
                    .rotationEffect(.degrees(petRotation), anchor: .bottom)
                    // 持續環境動畫層（待機輕微浮動 / 睡覺柔和呼吸）
                    .scaleEffect(
                        x: isSleepingState && isAmbientActive && !reduceMotion ? 1.035 : 1.0,
                        y: isSleepingState && isAmbientActive && !reduceMotion ? 0.965 : 1.0,
                        anchor: .bottom
                    )
                    .offset(
                        y: !isSleepingState && isAmbientActive && !reduceMotion ? -5 : 0
                    )

                // 右上角狀態／互動漂浮小氣泡
                if showReactionBadge || isSleepingState {
                    Text(isSleepingState ? "💤" : reactionEmoji)
                        .font(.system(size: min(max(petSize * 0.13, 18), 24)))
                        .padding(7)
                        .background(
                            Circle()
                                .fill(AppTheme.cardBackground.opacity(0.94))
                                .shadow(color: AppTheme.softShadow, radius: 6, x: 0, y: 3)
                        )
                        .offset(
                            x: petSize * 0.38,
                            y: (isAmbientActive && !reduceMotion ? -petSize * 0.34 : -petSize * 0.29)
                        )
                        .transition(.scale.combined(with: .opacity))
                }

                // 頂部狀態小標籤
                VStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(stageGlowColor)
                            .frame(width: 7, height: 7)

                        Text(statusHint)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textBrown)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(AppTheme.cardBackground.opacity(0.92))
                            .shadow(color: AppTheme.softShadow, radius: 4, x: 0, y: 2)
                    )
                    Spacer()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.32),
            value: imageName
        )
        .onAppear {
            startAmbientAnimationIfNeeded()
        }
        .onChange(of: reduceMotion) { _, newValue in
            if newValue {
                isAmbientActive = false
                resetTransientTransforms()
            } else {
                startAmbientAnimationIfNeeded()
            }
        }
        .onChange(of: interactionCount) { oldCount, newCount in
            guard newCount > oldCount else {
                // 重置時恢復初始視覺狀態
                reactionTask?.cancel()
                showReactionBadge = false
                resetTransientTransforms()
                return
            }
            triggerActionAnimation(for: lastAction)
        }
    }

    // MARK: - Pet Image or Fallback Placeholder
    @ViewBuilder
    private func petGraphic(size: CGFloat) -> some View {
        #if canImport(UIKit)
        if UIImage(named: imageName) != nil {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .accessibilityLabel("麻糬目前狀態圖片：\(statusHint)")
        } else {
            placeholderGraphic(size: size)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(named: imageName) ?? NSImage(contentsOfFile: "MochiDays/Assets.xcassets/\(imageName).imageset/\(imageName).png") {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .accessibilityLabel("麻糬目前狀態圖片：\(statusHint)")
        } else {
            placeholderGraphic(size: size)
        }
        #endif
    }

    private func placeholderGraphic(size: CGFloat) -> some View {
        // 若圖片素材尚未載入時的安全佔位圖（保持相同比例）
        ZStack {
            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .fill(AppTheme.cardBackground)
                .frame(width: size * 0.8, height: size * 0.7)
                .shadow(color: AppTheme.softShadow, radius: 10, x: 0, y: 5)

            VStack(spacing: 6) {
                Text(reactionEmoji)
                    .font(.system(size: size * 0.22))
                Text("麻糬")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textBrown)
            }
        }
        .frame(width: size, height: size)
    }

    /// 根據目前圖片狀態決定背景柔和光暈顏色
    private var stageGlowColor: Color {
        switch imageName {
        case "mochi_hungry":
            return AppTheme.fullness
        case "mochi_sleeping":
            return AppTheme.lavender
        case "mochi_sad":
            return AppTheme.happiness
        case "mochi_eating":
            return AppTheme.fullness
        case "mochi_playing":
            return AppTheme.energy
        case "mochi_petted":
            return AppTheme.primaryPink
        default:
            return AppTheme.primaryPink
        }
    }

    // MARK: - Animation Helpers

    private func startAmbientAnimationIfNeeded() {
        guard !reduceMotion else { return }
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            isAmbientActive = true
        }
    }

    private func resetTransientTransforms() {
        feedScale = 1.0
        playBounceY = 0.0
        petRotation = 0.0
    }

    /// 根據使用者點擊的互動類型執行非阻塞的原生動畫
    private func triggerActionAnimation(for action: PetAction) {
        reactionTask?.cancel()

        guard !reduceMotion else {
            return
        }

        reactionTask = Task { @MainActor in
            resetTransientTransforms()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                showReactionBadge = true
            }

            switch action {
            case .eating:
                // 2. 點擊餵食後的短暫縮放效果
                withAnimation(.spring(response: 0.22, dampingFraction: 0.5)) {
                    feedScale = 1.13
                }
                try? await Task.sleep(for: .milliseconds(180))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                    feedScale = 1.0
                }

            case .playing:
                // 3. 點擊玩耍後的彈跳效果
                withAnimation(.spring(response: 0.20, dampingFraction: 0.48)) {
                    playBounceY = -18
                    feedScale = 1.06
                }
                try? await Task.sleep(for: .milliseconds(170))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: 0.38, dampingFraction: 0.52)) {
                    playBounceY = 0
                    feedScale = 1.0
                }

            case .petting:
                // 4. 點擊摸摸後的左右擺動
                withAnimation(.easeInOut(duration: 0.13)) {
                    petRotation = -9
                }
                try? await Task.sleep(for: .milliseconds(130))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    petRotation = 9
                }
                try? await Task.sleep(for: .milliseconds(150))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: 0.30, dampingFraction: 0.6)) {
                    petRotation = 0
                }

            case .sleeping:
                // 5. 睡覺時配合柔和呼吸效果做輕微下沉放鬆
                withAnimation(.easeInOut(duration: 0.35)) {
                    feedScale = 0.96
                }
                try? await Task.sleep(for: .milliseconds(320))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    feedScale = 1.0
                }

            case .idle:
                resetTransientTransforms()
            }

            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                showReactionBadge = false
            }
        }
    }
}

#Preview {
    PetView(
        imageName: "mochi_idle",
        lastAction: .idle,
        interactionCount: 0,
        statusHint: "悠閒放空中"
    )
    .frame(height: 220)
    .padding()
    .background(AppTheme.background)
}

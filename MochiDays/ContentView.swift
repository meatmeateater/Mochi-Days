import SwiftUI

struct ContentView: View {
    // MARK: - Game State (@State 單一資料來源)
    @State private var fullness: Int = 60
    @State private var energy: Int = 70
    @State private var happiness: Int = 60
    @State private var interactionCount: Int = 0
    @State private var lastAction: PetAction = .idle
    @State private var message: String = "今天要一起做什麼呢？"

    // MARK: - UI Dialog State
    @State private var isShowingResetDialog: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Computed Properties (由既有 State 推導，避免重複儲存)

    /// 根據目前屬性與最後互動行為計算麻糬顯示圖片
    /// 優先順序：
    /// 1. fullness <= 20 → mochi_hungry
    /// 2. energy <= 20 → mochi_sleeping
    /// 3. happiness <= 20 → mochi_sad
    /// 4. 否則依照 lastAction 顯示對應圖片
    var petImageName: String {
        Self.resolvePetImageName(
            fullness: fullness,
            energy: energy,
            happiness: happiness,
            lastAction: lastAction
        )
    }

    /// 根據當前優先狀態推導狀態提示文字（供條件渲染與無障礙描述使用）
    private var currentStatusHint: String {
        if fullness <= 20 {
            return "肚子咕嚕叫"
        } else if energy <= 20 {
            return "眼皮好沉重"
        } else if happiness <= 20 {
            return "需要你陪陪"
        } else {
            switch lastAction {
            case .idle:
                return "悠閒放空中"
            case .eating:
                return "津津有味享用了飯糰"
            case .playing:
                return "開心地蹦蹦跳跳"
            case .sleeping:
                return "香甜進入夢鄉"
            case .petting:
                return "被摸摸覺得好幸福"
            }
        }
    }

    private let buttonGridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            // 溫暖奶油色背景與柔和裝飾圓圈
            AppTheme.background
                .ignoresSafeArea()

            backgroundDecoration

            VStack(spacing: 12) {
                headerSection

                statusCardSection

                PetView(
                    imageName: petImageName,
                    lastAction: lastAction,
                    interactionCount: interactionCount,
                    statusHint: currentStatusHint
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                dialogueBubbleSection

                actionButtonsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
        // 維持療癒亮色系設計配色，不因系統 Dark Mode 破壞畫面
        .preferredColorScheme(.light)
        .confirmationDialog(
            "確定要重新開始嗎？",
            isPresented: $isShowingResetDialog,
            titleVisibility: .visible
        ) {
            Button("重新開始", role: .destructive) {
                resetGame()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("麻糬的飽足度、活力值、快樂值與互動次數都會恢復為預設狀態。")
        }
    }

    // MARK: - Subviews

    /// 背景柔和粉彩光暈裝飾
    private var backgroundDecoration: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(AppTheme.primaryPink.opacity(0.14))
                    .frame(width: 220, height: 220)
                    .blur(radius: 20)
                    .position(x: proxy.size.width * 0.12, y: proxy.size.height * 0.08)

                Circle()
                    .fill(AppTheme.lavender.opacity(0.16))
                    .frame(width: 240, height: 240)
                    .blur(radius: 24)
                    .position(x: proxy.size.width * 0.88, y: proxy.size.height * 0.48)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// 6.1 Header：標題、副標題與右上角重置按鈕
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Mochi Days")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppTheme.textBrown)

                    Text("麻糬日常")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textBrown)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(AppTheme.primaryPink.opacity(0.38))
                        )
                }

                Text("和麻糬一起度過的每一天")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.subtleTextBrown)
            }

            Spacer()

            Button {
                isShowingResetDialog = true
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.textBrown)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(AppTheme.cardBackground)
                            .shadow(color: AppTheme.softShadow, radius: 6, x: 0, y: 3)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(AppTheme.cardBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(MochiPressButtonStyle())
            .accessibilityLabel("重新開始")
            .accessibilityHint("點擊後將詢問是否重置麻糬的所有狀態")
        }
    }

    /// 6.2 Status Card：寵物名稱、互動次數與三項屬性 ProgressView
    private var statusCardSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryPink.opacity(0.28))
                            .frame(width: 32, height: 32)
                        Text("🍡")
                            .font(.system(size: 16))
                    }

                    Text("麻糬")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textBrown)
                }

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.lavender)

                    Text("互動次數 \(interactionCount)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.textBrown)
                        .contentTransition(.numericText(value: Double(interactionCount)))
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppTheme.lavender.opacity(0.24))
                )
            }

            Divider()
                .overlay(AppTheme.cardBorder)

            VStack(spacing: 10) {
                StatBarView(
                    title: "飽足度",
                    systemImage: "fork.knife",
                    value: fullness,
                    color: AppTheme.fullness
                )

                StatBarView(
                    title: "活力值",
                    systemImage: "bolt.fill",
                    value: energy,
                    color: AppTheme.energy
                )

                StatBarView(
                    title: "快樂值",
                    systemImage: "heart.fill",
                    value: happiness,
                    color: AppTheme.happiness
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .strokeBorder(AppTheme.cardBorder, lineWidth: 1)
        )
    }

    /// 6.4 Dialogue Bubble：白色圓角對話氣泡，具淡入切換效果
    private var dialogueBubbleSection: some View {
        VStack(spacing: 0) {
            // 朝向麻糬的上方小尖角
            TrianglePointer()
                .fill(AppTheme.cardBackground)
                .frame(width: 18, height: 9)
                .offset(y: 1)

            HStack(spacing: 8) {
                Text(message)
                    .id(message)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textBrown)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .scale(scale: 0.97))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.bubbleCornerRadius, style: .continuous)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.softShadow, radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.bubbleCornerRadius, style: .continuous)
                    .strokeBorder(AppTheme.primaryPink.opacity(0.35), lineWidth: 1.2)
            )
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: message)
    }

    /// 6.5 Action Buttons：底部 2x2 互動按鈕網格
    private var actionButtonsSection: some View {
        LazyVGrid(columns: buttonGridColumns, spacing: 10) {
            // 第一排：🍙 餵食 | 🎾 玩耍
            ActionButtonView(
                emoji: "🍙",
                title: "餵食",
                subtitle: "飽足度 +25",
                systemImage: "fork.knife",
                tintColor: AppTheme.fullness,
                action: feedPet
            )

            ActionButtonView(
                emoji: "🎾",
                title: "玩耍",
                subtitle: "快樂值 +25",
                systemImage: "tennisball.fill",
                tintColor: AppTheme.primaryPink,
                action: playWithPet
            )

            // 第二排：🌙 睡覺 | ❤️ 摸摸
            ActionButtonView(
                emoji: "🌙",
                title: "睡覺",
                subtitle: "活力值 +30",
                systemImage: "moon.zzz.fill",
                tintColor: AppTheme.lavender,
                action: putPetToSleep
            )

            ActionButtonView(
                emoji: "❤️",
                title: "摸摸",
                subtitle: "快樂值 +10",
                systemImage: "hand.raised.fill",
                tintColor: AppTheme.happiness,
                action: petMochi
            )
        }
    }

    // MARK: - Core Gameplay Logic

    /// 4.1 餵食：若飽足度已達 100 則拒絕並提示；否則增加飽足度與快樂值
    private func feedPet() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.8)) {
            Self.applyFeed(
                fullness: &fullness,
                happiness: &happiness,
                interactionCount: &interactionCount,
                lastAction: &lastAction,
                message: &message
            )
        }
    }

    /// 4.2 玩耍：優先檢查活力值 (< 20)，其次檢查飽足度 (< 10)；通過後更新三項屬性
    private func playWithPet() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.8)) {
            Self.applyPlay(
                fullness: &fullness,
                energy: &energy,
                happiness: &happiness,
                interactionCount: &interactionCount,
                lastAction: &lastAction,
                message: &message
            )
        }
    }

    /// 4.3 睡覺：即使 energy 已達 100 仍可睡覺，數值透過 clamp 限制於 0...100
    private func putPetToSleep() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.8)) {
            Self.applySleep(
                fullness: &fullness,
                energy: &energy,
                interactionCount: &interactionCount,
                lastAction: &lastAction,
                message: &message
            )
        }
    }

    /// 4.4 摸摸：增加快樂值並更新狀態為 petting
    private func petMochi() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 0.8)) {
            Self.applyPet(
                happiness: &happiness,
                interactionCount: &interactionCount,
                lastAction: &lastAction,
                message: &message
            )
        }
    }

    /// 9. 重置功能：將所有狀態還原為初始預設值
    private func resetGame() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.82)) {
            Self.applyReset(
                fullness: &fullness,
                energy: &energy,
                happiness: &happiness,
                interactionCount: &interactionCount,
                lastAction: &lastAction,
                message: &message
            )
        }
    }

    // MARK: - Pure Helpers & State Transitions (Reusable & Testable)

    static func applyFeed(
        fullness: inout Int,
        happiness: inout Int,
        interactionCount: inout Int,
        lastAction: inout PetAction,
        message: inout String
    ) {
        guard fullness < 100 else {
            message = "已經吃飽啦！"
            return
        }

        fullness = clamp(fullness + 25)
        happiness = clamp(happiness + 5)
        interactionCount += 1
        lastAction = .eating
        message = "好好吃！謝謝你～"
    }

    static func applyPlay(
        fullness: inout Int,
        energy: inout Int,
        happiness: inout Int,
        interactionCount: inout Int,
        lastAction: inout PetAction,
        message: inout String
    ) {
        // 優先順序 1：活力不足時拒絕玩耍
        if energy < 20 {
            message = "我想先休息一下……"
            return
        }

        // 優先順序 2：過度飢餓時拒絕玩耍
        if fullness < 10 {
            message = "肚子餓了，先吃點東西吧！"
            return
        }

        fullness = clamp(fullness - 10)
        energy = clamp(energy - 20)
        happiness = clamp(happiness + 25)
        interactionCount += 1
        lastAction = .playing
        message = "耶！再玩一次！"
    }

    static func applySleep(
        fullness: inout Int,
        energy: inout Int,
        interactionCount: inout Int,
        lastAction: inout PetAction,
        message: inout String
    ) {
        energy = clamp(energy + 30)
        fullness = clamp(fullness - 10)
        interactionCount += 1
        lastAction = .sleeping
        message = "呼嚕……晚安。"
    }

    static func applyPet(
        happiness: inout Int,
        interactionCount: inout Int,
        lastAction: inout PetAction,
        message: inout String
    ) {
        happiness = clamp(happiness + 10)
        interactionCount += 1
        lastAction = .petting
        message = "嘿嘿，好舒服！"
    }

    static func applyReset(
        fullness: inout Int,
        energy: inout Int,
        happiness: inout Int,
        interactionCount: inout Int,
        lastAction: inout PetAction,
        message: inout String
    ) {
        fullness = 60
        energy = 70
        happiness = 60
        interactionCount = 0
        lastAction = .idle
        message = "今天要一起做什麼呢？"
    }

    /// 4.5 確保所有寵物屬性皆維持在 0...100 範圍內
    static func clamp(_ value: Int) -> Int {
        min(max(value, 0), 100)
    }

    /// 5. 依照既定優先順序決定麻糬圖片名稱
    static func resolvePetImageName(
        fullness: Int,
        energy: Int,
        happiness: Int,
        lastAction: PetAction
    ) -> String {
        if fullness <= 20 {
            return "mochi_hungry"
        } else if energy <= 20 {
            return "mochi_sleeping"
        } else if happiness <= 20 {
            return "mochi_sad"
        } else {
            return lastAction.defaultImageName
        }
    }
}

/// 對話框上方指向麻糬的小三角形
private struct TrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ContentView()
}

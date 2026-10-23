import SwiftUI

/// 底部 2x2 互動操作按鈕元件
struct ActionButtonView: View {
    let emoji: String
    let title: String
    let subtitle: String
    let systemImage: String
    let tintColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tintColor.opacity(0.24))
                        .frame(width: 38, height: 38)

                    Text(emoji)
                        .font(.system(size: 19))
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textBrown)
                            .lineLimit(1)

                        Image(systemName: systemImage)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(tintColor)
                    }

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.subtleTextBrown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.cardBackground,
                                tintColor.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius, style: .continuous)
                    .strokeBorder(tintColor.opacity(0.32), lineWidth: 1.2)
            )
            .shadow(color: AppTheme.softShadow, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(MochiPressButtonStyle())
        .accessibilityLabel("\(emoji) \(title)")
        .accessibilityHint(subtitle)
    }
}

/// 按下時具有柔和縮放回饋的 ButtonStyle
struct MochiPressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(
                reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.65),
                value: configuration.isPressed
            )
    }
}

#Preview {
    HStack(spacing: 12) {
        ActionButtonView(
            emoji: "🍙",
            title: "餵食",
            subtitle: "飽足度 +25",
            systemImage: "fork.knife",
            tintColor: AppTheme.fullness,
            action: {}
        )
        ActionButtonView(
            emoji: "🎾",
            title: "玩耍",
            subtitle: "快樂值 +25",
            systemImage: "tennisball.fill",
            tintColor: AppTheme.primaryPink,
            action: {}
        )
    }
    .padding()
    .background(AppTheme.background)
}

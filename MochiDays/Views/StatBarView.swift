import SwiftUI

/// 單一屬性進度條元件（飽足度、活力值、快樂值）
struct StatBarView: View {
    let title: String
    let systemImage: String
    let value: Int
    let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// 當數值低於或等於 20 時顯示提醒狀態
    private var isLow: Bool {
        value <= 20
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 16)

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textBrown)

                if isLow {
                    Text("偏低")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.cardBackground)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppTheme.primaryPink)
                        )
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                Text("\(value) / 100")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(isLow ? Color(red: 0.82, green: 0.36, blue: 0.36) : AppTheme.subtleTextBrown)
                    .contentTransition(.numericText(value: Double(value)))
            }

            ProgressView(value: Double(value), total: 100.0)
                .tint(color)
                .progressViewStyle(MochiCapsuleProgressStyle(color: color, reduceMotion: reduceMotion))
                .accessibilityLabel(title)
                .accessibilityValue("\(value) / 100")
        }
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.82), value: value)
    }
}

/// 圓角膠囊風格的 ProgressViewStyle，讓原生 ProgressView 呈現柔和療癒外觀
struct MochiCapsuleProgressStyle: ProgressViewStyle {
    let color: Color
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        let fraction = min(max(configuration.fractionCompleted ?? 0, 0), 1)

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.trackBackground)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.88), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geometry.size.width * fraction, fraction > 0 ? 10 : 0))
                    .animation(
                        reduceMotion ? .none : .spring(response: 0.45, dampingFraction: 0.8),
                        value: fraction
                    )
            }
        }
        .frame(height: 10)
    }
}

#Preview {
    VStack(spacing: 12) {
        StatBarView(title: "飽足度", systemImage: "fork.knife", value: 60, color: AppTheme.fullness)
        StatBarView(title: "活力值", systemImage: "bolt.fill", value: 70, color: AppTheme.energy)
        StatBarView(title: "快樂值", systemImage: "heart.fill", value: 15, color: AppTheme.happiness)
    }
    .padding()
    .background(AppTheme.cardBackground)
}

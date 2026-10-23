import SwiftUI

/// 集中管理 Mochi Days 療癒風格配色與視覺常數
enum AppTheme {
    // MARK: - Core Palette
    /// 溫暖奶油底色 #FFF9F0
    static let background = Color(red: 1.000, green: 0.976, blue: 0.941)
    /// 主題粉紅 #FFB8B8
    static let primaryPink = Color(red: 1.000, green: 0.722, blue: 0.722)
    /// 柔和薰衣草紫 #CDBAF4
    static let lavender = Color(red: 0.804, green: 0.729, blue: 0.957)
    /// 溫暖深棕文字 #5D4A42
    static let textBrown = Color(red: 0.365, green: 0.290, blue: 0.259)
    /// 卡片純白背景 #FFFFFF
    static let cardBackground = Color(red: 1.000, green: 1.000, blue: 1.000)

    // MARK: - Stat Bar Colors
    /// 飽足度配色 #EAA564
    static let fullness = Color(red: 0.918, green: 0.647, blue: 0.392)
    /// 活力值配色 #DAB756
    static let energy = Color(red: 0.855, green: 0.718, blue: 0.337)
    /// 快樂值配色 #E79CAB
    static let happiness = Color(red: 0.906, green: 0.612, blue: 0.671)

    // MARK: - Supporting Accents
    /// 次要文字與提示用柔和淺棕
    static let subtleTextBrown = Color(red: 0.365, green: 0.290, blue: 0.259).opacity(0.68)
    /// 進度條底軌淡米色
    static let trackBackground = Color(red: 0.953, green: 0.918, blue: 0.875)
    /// 卡片柔和陰影色
    static let softShadow = Color(red: 0.365, green: 0.290, blue: 0.259).opacity(0.08)
    /// 細緻邊框色
    static let cardBorder = Color(red: 0.365, green: 0.290, blue: 0.259).opacity(0.07)

    // MARK: - Layout Constants
    static let cardCornerRadius: CGFloat = 24
    static let buttonCornerRadius: CGFloat = 20
    static let bubbleCornerRadius: CGFloat = 22
}

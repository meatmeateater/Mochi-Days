import Foundation

/// 麻糬的互動行為狀態
enum PetAction: String, CaseIterable, Equatable {
    case idle
    case eating
    case playing
    case sleeping
    case petting

    /// 對應行為的預設角色圖片名稱（當無低數值警示時的圖片）
    var defaultImageName: String {
        switch self {
        case .idle:
            return "mochi_idle"
        case .eating:
            return "mochi_eating"
        case .playing:
            return "mochi_playing"
        case .sleeping:
            return "mochi_sleeping"
        case .petting:
            return "mochi_petted"
        }
    }
}

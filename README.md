# Mochi Days｜麻糬日常

**Mochi Days｜麻糬日常** 是一款使用原生 **SwiftUI** 開發的日系療癒風格電子寵物養成遊戲。玩家可以透過「餵食」、「玩耍」、「睡覺」與「摸摸」四種日常互動照顧可愛的虛擬生物「麻糬」，觀察牠隨著身體狀態與情緒變化所展現的不同表情、動畫與對話回饋。

---

## 1. 專案名稱與簡介

- **專案名稱**：Mochi Days｜麻糬日常
- **開發語言**：Swift 5
- **UI 框架**：SwiftUI
- **最低系統需求**：iOS 17.0+（Portrait 直向介面）
- **外部依賴**：無（100% Apple 原生框架）

本專案以溫暖奶油色系（Cream & Soft Pastel Palette）打造舒適的視覺體驗，並完整支援無障礙「減少動態效果（Reduce Motion）」與不同尺寸 iPhone 螢幕適配。

---

## 2. 開發動機

本專案為 iOS 程式設計課程作業，旨在透過互動性明確的電子寵物養成遊戲，實踐並展示 **SwiftUI State-driven UI（狀態驅動介面）** 的核心設計哲學：

- 以單一資料來源（Single Source of Truth）管理寵物屬性與互動狀態。
- 不額外重複儲存可推導的 UI 狀態，而是透過 **Computed Properties** 即時從屬性計算角色圖片與狀態提示文字。
- 讓每一次按鈕點擊都能透過修改 `@State` 自動觸發畫面更新、條件渲染（Conditional Rendering）與流暢的原生過渡動畫。

---

## 3. 功能介紹

### 四種日常照顧互動
- **🍙 餵食（Feed）**：為麻糬送上飯糰，補充飽足度並提升快樂值。
- **🎾 玩耍（Play）**：陪伴麻糬玩球，大幅增加快樂值，同時消耗飽足度與活力值。
- **🌙 睡覺（Sleep）**：讓麻糬休息入睡，回復活力值並微幅消耗飽足度。
- **❤️ 摸摸（Pet）**：溫柔摸摸麻糬，提升快樂值並觸發撒嬌搖擺動畫。

### 七種角色狀態與表情圖片
麻糬擁有七種專屬透明背景角色插圖，並依身體狀態優先順序自動切換：
1. **`mochi_hungry`**：飽足度偏低（`fullness <= 20`）時，委屈摸著肚子提醒玩家餵食。
2. **`mochi_sleeping`**：活力值偏低（`energy <= 20`）或執行睡覺互動時，趴下閉眼休息。
3. **`mochi_sad`**：快樂值偏低（`happiness <= 20`）時，含淚呈現失落表情。
4. **`mochi_idle`**：一般待機狀態，悠閒放空並輕微上下漂浮。
5. **`mochi_eating`**：餵食後的開心享用飯糰狀態。
6. **`mochi_playing`**：玩耍時的興奮跳躍狀態。
7. **`mochi_petted`**：被摸摸時的幸福害羞狀態。

### 防呆機制與安全重置
- **防呆提示**：吃飽時拒絕過度餵食；太累（`energy < 20`）或太餓（`fullness < 10`）時拒絕玩耍並給出貼心對話提示，且不計入有效互動次數。
- **低數值警示**：當任一屬性 `<= 20` 時，進度條旁會透過條件渲染自動顯示「偏低」標籤。
- **重新開始確認**：右上角提供重置功能，點擊後會先彈出 `confirmationDialog` 確認視窗，避免誤觸重置進度。

---

## 4. 技術架構

- **Swift & SwiftUI**：以輕量化元件架構（Component-based Architecture）拆分視圖。
- **`@State` 單向資料流**：由 `ContentView` 集中持有遊戲核心狀態，子視圖透過參數與閉包（Action Closure）接收資料與回傳事件。
- **Computed Properties**：根據 `fullness`、`energy`、`happiness` 與 `lastAction` 即時推導 `petImageName` 與 `currentStatusHint`。
- **`ProgressView` & 自訂 `ProgressViewStyle`**：以 `MochiCapsuleProgressStyle` 封裝膠囊圓角進度條與數值平滑動畫。
- **SwiftUI Native Animations**：結合 `.spring`、`.easeInOut`、`.repeatForever`、`.transition` 與 `.contentTransition(.numericText())`，實作待機浮動、餵食縮放、玩耍彈跳、摸摸擺動與睡覺呼吸效果。

---

## 5. 專案檔案結構

```text
MochiDays/
├── MochiDays.xcodeproj/              # Xcode 專案與 Scheme 設定
├── MochiDays/
│   ├── MochiDaysApp.swift            # App 進入點 (@main)
│   ├── ContentView.swift             # 主畫面、@State 遊戲狀態核心與互動規則邏輯
│   ├── Models/
│   │   └── PetAction.swift           # 寵物互動行為列舉 (idle / eating / playing / sleeping / petting)
│   ├── Views/
│   │   ├── PetView.swift             # 寵物圖片顯示、環境浮動／睡眠呼吸與點擊互動動畫
│   │   ├── StatBarView.swift         # 單項屬性進度條元件與低數值條件渲染標籤
│   │   └── ActionButtonView.swift    # 底部 2x2 圓角互動按鈕與按壓縮放 ButtonStyle
│   ├── Utilities/
│   │   └── AppTheme.swift            # 集中管理配色 (Color Palette) 與圓角常數
│   └── Assets.xcassets/              # 7 張麻糬角色圖片 (mochi_*)、AppIcon 與 AccentColor
└── MochiDaysTests/
    └── MochiDaysTests.swift          # 核心遊戲邏輯與狀態優先順序 XCTest 單元測試
```

---

## 6. 核心技術

### State 驅動畫面與 Computed Property 狀態推導

在 `ContentView.swift` 中，不額外使用 `@State` 儲存圖片名稱，而是透過 `petImageName` 即時由當前屬性推導：

```swift
// MARK: - Game State (@State 單一資料來源)
@State private var fullness: Int = 60
@State private var energy: Int = 70
@State private var happiness: Int = 60
@State private var interactionCount: Int = 0
@State private var lastAction: PetAction = .idle
@State private var message: String = "今天要一起做什麼呢？"

/// 依照既定優先順序決定麻糬圖片名稱
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
```

當使用者點擊互動按鈕時，只需在 `withAnimation` 中更新狀態，SwiftUI 即會自動同步更新進度條、角色圖片與對話氣泡：

```swift
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
```

---

## 7. 遊戲操作與規則

所有寵物屬性皆透過 `clamp(_:)` 限制於 **`0 ～ 100`** 範圍內：

| 互動按鈕 | 飽足度 (Fullness) | 活力值 (Energy) | 快樂值 (Happiness) | 互動次數 | 預設對話／條件限制 |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **🍙 餵食 (Feed)** | `+25` | `0` | `+5` | `+1` | 「好好吃！謝謝你～」<br>*(若 `fullness == 100` 則拒絕並顯示「已經吃飽啦！」)* |
| **🎾 玩耍 (Play)** | `-10` | `-20` | `+25` | `+1` | 「耶！再玩一次！」<br>*(若 `energy < 20` 顯示「我想先休息一下……」；若 `fullness < 10` 顯示「肚子餓了，先吃點東西吧！」)* |
| **🌙 睡覺 (Sleep)** | `-10` | `+30` | `0` | `+1` | 「呼嚕……晚安。」<br>*(即使 `energy == 100` 仍可睡覺，數值上限維持 100)* |
| **❤️ 摸摸 (Pet)** | `0` | `0` | `+10` | `+1` | 「嘿嘿，好舒服！」 |
| **🔄 重新開始 (Reset)** | 重置為 `60` | 重置為 `70` | 重置為 `60` | 重置為 `0` | 「今天要一起做什麼呢？」 |

---

## 8. 執行方式

1. 確認 Mac 已安裝 **Xcode 15.0 或以上版本**（支援 iOS 17 SDK）。
2. 在專案根目錄雙擊開啟 `MochiDays.xcodeproj`，或於終端機執行：
   ```bash
   open MochiDays.xcodeproj
   ```
3. 於 Xcode 頂部工具列選擇 Scheme **`MochiDays`**，並將執行目標設為 **iPhone 12 Pro**（或其他 iPhone 模擬器）。
4. 按下 **`Cmd + R`** 編譯並啟動 App。
5. 若欲執行單元測試，可於 Xcode 按下 **`Cmd + U`** 執行 `MochiDaysTests`。

---

## 9. 專案截圖

> **TODO**：請於 Xcode 模擬器啟動 App 後擷取實際畫面，並將圖片放入 `Screenshots/` 資料夾後更新下方路徑：

- **一般待機畫面**
  - `<!-- TODO: 放入一般待機畫面截圖，例如 ![一般待機畫面](Screenshots/idle.png) -->`
- **玩耍／開心畫面**
  - `<!-- TODO: 放入玩耍或餵食開心畫面截圖，例如 ![玩耍開心畫面](Screenshots/playing.png) -->`
- **飢餓或疲倦畫面**
  - `<!-- TODO: 放入飽足度或活力偏低時的警示畫面截圖，例如 ![飢餓或疲倦畫面](Screenshots/hungry_or_tired.png) -->`

---

## 10. 未來改進

- **資料持久化（Persistence）**：透過 `@AppStorage` 或 `SwiftData` 儲存麻糬的狀態與累積互動天數，重新開啟 App 時延續養成進度。
- **親密度與等級系統**：根據累積互動次數解鎖不同成長階段、頭飾配件或專屬台詞。
- **時間自然衰減機制**：結合計時器與背景時間差計算，讓麻糬的飽足度與活力隨真實時間自然變化。
- **音效與觸覺回饋（Haptics）**：加入輕柔的音效與 `sensoryFeedback`，提升互動沉浸感。

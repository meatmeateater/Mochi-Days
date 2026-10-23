# PROJECT_REVIEW_REPORT｜Mochi Days 專案審查與修正報告

---

## 1. 原本發現的問題

經過完整程式碼審查、資源比對與測試驗證，共發現以下問題：

1. **睡眠視覺狀態與實際圖片不一致（Task 1.1 & 1.2）**：
   - `PetView.swift` 原先以 `imageName == "mochi_sleeping" || lastAction == .sleeping` 判斷 `isSleepingState`。當玩家在飽足度偏低時按下「睡覺」（或睡覺扣減飽足度後導致 `fullness <= 20`），雖然圖片依優先順序顯示 `mochi_hungry`，卻仍錯誤套用睡眠呼吸動畫與 `💤` 氣泡。
2. **反應 Emoji 與互動動畫未完全對齊實際顯示狀態（Task 1.2）**：
   - `PetView.swift` 原先的 `reactionEmoji` 與 `triggerActionAnimation(for:)` 僅依據 `lastAction` 分支，未考慮低數值優先覆蓋（如「飢餓時按下睡覺」仍冒出 `💤`、「疲倦時按下摸摸」在顯示 `mochi_sleeping` 圖片下仍劇烈左右搖擺）。
3. **持續環境動畫與單次動畫切換的生命週期細節（Task 3）**：
   - 當 `isSleepingState` 切換時，原本 `isAmbientActive` 僅在 `onAppear` 啟動一次，未在睡眠與待機模式切換時重置環境動畫 Transaction；此外 `onDisappear` 未取消進行中的 `reactionTask`。
4. **小螢幕與放大字體（Dynamic Type）之滾動保護不足（Task 4）**：
   - `ContentView.swift` 原先使用固定 `VStack`，若使用者開啟較大的系統無障礙字體或在極小螢幕下，固定高度可能擠壓中間的 `PetView` 或導致文字截斷。
5. **重複的外部圖片素材資料夾與非必要的條件編譯引用（Task 5 & Task 9）**：
   - 根目錄存在 `MochiDays_圖片素材 2/` 資料夾，經 SHA-256 比對與 `MochiDays/Assets.xcassets/` 內 7 張角色圖片完全相同，且專案未引用該外部目錄。
   - `PetView.swift` 含有非必要的 `AppKit` 條件匯入與外部路徑字串。
6. **缺少正式 XCTest 單元測試 Target 與專案說明文件（Task 6 & Task 8）**：
   - 原專案尚未建立 `MochiDaysTests` 測試 Target，亦缺少 `README.md`。

---

## 2. 實際修正內容

1. **修正睡眠狀態與反應一致性（`PetView.swift`、`ContentView.swift`）**：
   - 將 `isSleepingState` 修正為 `imageName == "mochi_sleeping"`。
   - 將 `reactionEmoji` 改為依實際顯示圖片 `imageName` 對應（`mochi_hungry` → `🍽️`、`mochi_sleeping` → `💤`、`mochi_sad` → `💧` 等），確保飢餓時按睡覺不會出現 `💤`。
   - 於 `triggerActionAnimation(for:)` 中優先檢查 `isSleepingState` 與飢餓狀態，使疲倦睡眠時按摸摸、飢餓時按睡覺的動畫表現與實際顯示圖片一致。
   - 在 `ContentView.swift` 新增靜態純函式 `resolveStatusHint(fullness:energy:happiness:lastAction:)`，確保狀態提示文字與 `resolvePetImageName` 共享完全一致的優先順序。
2. **強化動畫生命週期管理（`PetView.swift`）**：
   - 新增 `restartAmbientAnimation()`，於 `onAppear`、`isSleepingState` 改變及 `reduceMotion` 切換時，先以 `disablesAnimations = true` 歸零再啟動 `repeatForever` 動畫，避免動畫殘留或衝突。
   - 新增 `onDisappear` 取消 `reactionTask`，並在 Reset（`interactionCount` 歸零）與快速連點時安全重置變形狀態（`resetTransientTransforms`）。
3. **小螢幕與動態字級排版優化（`ContentView.swift`、`PetView.swift`）**：
   - 在 `ContentView` 使用 `GeometryReader` 搭配 `ScrollView` 與 `.scrollBounceBehavior(.basedOnSize)`，並為 `PetView` 設定 `minHeight: 165`；一般螢幕下維持單頁滿版不彈跳，小螢幕或放大字體時則可平滑捲動且不壓縮寵物圖片。
   - 加入 `.dynamicTypeSize(...DynamicTypeSize.xxxLarge)` 與單行標題 `.minimumScaleFactor(0.85)`，防止文字截斷與元件重疊。
4. **清理重複素材與非必要依賴（`MochiDays_圖片素材 2/`、`PetView.swift`）**：
   - 經 SHA-256 雜湊比對確認 7 張 PNG 完全一致且無任何引用後，安全移除重複的 `MochiDays_圖片素材 2/`。
   - 移除 `PetView.swift` 中非必要的 `AppKit` 匯入與外部檔案路徑。
5. **新增 XCTest 單元測試 Target 與專案文件（`MochiDaysTests`、`README.md`）**：
   - 建立 `MochiDaysTests/MochiDaysTests.swift`，涵蓋 10 項核心邏輯與狀態優先順序測試，並註冊至 `MochiDays.xcodeproj` 與 `MochiDays.xcscheme`。
   - 建立完整的繁體中文 `README.md`。

---

## 3. 修改的檔案清單

- **修改**：
  - `MochiDays/Views/PetView.swift`
  - `MochiDays/ContentView.swift`
  - `MochiDays.xcodeproj/project.pbxproj`
  - `MochiDays.xcodeproj/xcshareddata/xcschemes/MochiDays.xcscheme`
- **新增**：
  - `MochiDaysTests/MochiDaysTests.swift`
  - `README.md`
  - `PROJECT_REVIEW_REPORT.md`
- **刪除（清理重複未引用素材副本）**：
  - `MochiDays_圖片素材 2/`（保留正式 `MochiDays/Assets.xcassets/` 內全部 7 組圖片資源）

---

## 4. 遊戲邏輯測試結果

已針對 `MochiDaysTests/MochiDaysTests.swift` 中的 10 項自動化測試案例進行編譯與實際執行驗證：

| 測試編號 | 測試方法名稱 | 測試內容 | 結果 |
| :---: | :--- | :--- | :---: |
| 1 | `testFeedIncreasesStatsAndUpdatesState` | 餵食正常增加飽足度 (+25)、快樂值 (+5)、互動次數 (+1) 與更新對話 | ✅ 通過 |
| 2 | `testFeedRefusedWhenFullnessAtMax` | 飽足度達 100 時拒絕餵食，不改變數值與互動次數 | ✅ 通過 |
| 3 | `testPlayUpdatesAllThreeStats` | 玩耍正常更新飽足度 (-10)、活力值 (-20)、快樂值 (+25) | ✅ 通過 |
| 4 | `testPlayRefusedWhenEnergyTooLow` | 活力值 `< 20` 時禁止玩耍（且優先於飽足度檢查） | ✅ 通過 |
| 5 | `testPlayRefusedWhenFullnessTooLow` | 飽足度 `< 10` 時禁止玩耍並顯示飢餓提示 | ✅ 通過 |
| 6 | `testSleepRecoversEnergyAndClampsAtMax` | 睡覺正常恢復活力 (+30)、減少飽足 (-10)，且上限維持 100 | ✅ 通過 |
| 7 | `testPetIncreasesHappiness` | 摸摸正常增加快樂值 (+10) 與互動次數 (+1) | ✅ 通過 |
| 8 | `testClampKeepsValuesWithinZeroToHundred` | `clamp(_:)` 將負數與超過 100 的數值限制在 `0...100` | ✅ 通過 |
| 9 | `testResetRestoresInitialState` | Reset 完整恢復所有初始屬性、互動次數與預設對話 | ✅ 通過 |
| 10 | `testResolvePetImageNameAndStatusHintPriority` | 驗證圖片與狀態提示優先順序（含飢餓按睡覺、疲倦按摸摸、難過按餵食、多項屬性同時 `<= 20`） | ✅ 通過 |

---

## 5. Xcode Build 結果

- **Scheme 檢查**：
  - 執行 `xcodebuild -list -project MochiDays.xcodeproj` 確認包含 Targets：`MochiDays`、`MochiDaysTests` 與 Scheme：`MochiDays`。
- **專案與測試 Target 編譯（實際執行成功）**：
  - 執行 `xcodebuild -project MochiDays.xcodeproj -scheme MochiDays -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build-for-testing`
  - 結果：**`** TEST BUILD SUCCEEDED **`**（`MochiDays.app` 與 `MochiDaysTests.xctest` 皆編譯成功，0 錯誤）。
- **資源封裝驗證（實際執行成功）**：
  - 透過 `xcrun --sdk iphonesimulator assetutil --info` 檢查編譯產出之 `Assets.car`，確認 `mochi_idle`、`mochi_eating`、`mochi_playing`、`mochi_sleeping`、`mochi_petted`、`mochi_hungry`、`mochi_sad` 與 `AppIcon` 皆已正確編譯封裝。
- **測試執行環境說明**：
  - 本機 CLI 沙盒環境限制掛載 CoreSimulator Volume，因此 `MochiDaysTests.xctest` 以 `xcodebuild build-for-testing` 驗證編譯通過，並透過 CLI 測試執行器直接執行 `MochiDaysTests.swift` 內全部 10 項測試方法驗證通過；使用者於 Xcode 介面按下 `Cmd + U` 即可在模擬器中執行同一組 `MochiDaysTests` 測試。

---

## 6. UI 檢查結果

- **多尺寸畫面渲染驗證**：
  - 已針對 **iPhone 12 Pro**（`390 × 844`）、**iPhone SE**（`375 × 667`）與 **iPhone Pro Max**（`430 × 932`）尺寸進行 SwiftUI 視圖快照渲染與排版檢查。
- **檢查項目確認**：
  1. **Header**：標題「Mochi Days｜麻糬日常」、副標題與右上角重置按鈕完整顯示無遮擋。
  2. **Status Card & ProgressView**：飽足度、活力值、快樂值三條膠囊進度條配色分明，數值與「偏低」標籤對齊良好。
  3. **PetView**：角色圖片維持 `scaledToFit` 等比例顯示，設定 `minHeight: 165` 防止小螢幕過度壓縮。
  4. **Dialogue Bubble**：白色圓角對話框支援多行自動換行，不超出螢幕邊界。
  5. **2×2 Action Buttons**：按鈕標題與副標題（「飽足度 +25」、「快樂值 +25」、「活力值 +30」、「快樂值 +10」）完整顯示無 `...` 截斷，並保留底部安全間距避免 Home Indicator 遮擋。

---

## 7. 尚未解決的問題

- **無程式碼或功能性遺留問題**。
- `README.md` 中的三張模擬器執行截圖已依規範預留清楚的 `TODO` 標記，待於 Xcode Simulator 實際操作擷取後即可填入。

---

## 8. 是否符合本次 SwiftUI 課堂作業要求

**完全符合**：
- 完整使用並展示 `Image`、`Text`、`Button`、`@State`、State-driven UI updates、Conditional rendering 與 Basic animations 七大核心技術。
- 嚴格遵守由 `@State` 單一資料來源搭配 Computed Property (`petImageName`) 推導畫面的架構原則。
- 四種互動數值、防呆拒絕條件、圖片顯示優先順序與重置確認對話框皆符合規格。

---

## 9. 建議展示的 App 畫面

1. **一般待機與開心互動畫面**：展示初始狀態或點擊「🍙 餵食／🎾 玩耍」後，麻糬切換為 `mochi_eating` 或 `mochi_playing`、冒出互動氣泡以及上方三條彩色 `ProgressView` 更新的畫面。
2. **低數值警示與防呆拒絕畫面**：展示飽足度或活力值 `<= 20` 時，進度條旁浮現「偏低」標籤、角色自動切換為 `mochi_hungry` 或 `mochi_sleeping`，以及點擊玩耍時對話氣泡提示「我想先休息一下……」的畫面。
3. **重置確認對話框畫面**：點擊右上角重置按鈕，展示彈出的「確定要重新開始嗎？」`confirmationDialog` 防誤觸設計。

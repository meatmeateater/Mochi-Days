import XCTest
@testable import MochiDays

final class MochiDaysTests: XCTestCase {

    // 1. Feed 正常增加數值
    func testFeedIncreasesStatsAndUpdatesState() {
        var fullness = 60
        var happiness = 60
        var interactionCount = 0
        var lastAction: PetAction = .idle
        var message = "今天要一起做什麼呢？"

        ContentView.applyFeed(
            fullness: &fullness,
            happiness: &happiness,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )

        XCTAssertEqual(fullness, 85)
        XCTAssertEqual(happiness, 65)
        XCTAssertEqual(interactionCount, 1)
        XCTAssertEqual(lastAction, .eating)
        XCTAssertEqual(message, "好好吃！謝謝你～")
    }

    // 2. Feed 達到上限時拒絕操作
    func testFeedRefusedWhenFullnessAtMax() {
        var fullness = 100
        var happiness = 70
        var interactionCount = 2
        var lastAction: PetAction = .playing
        var message = "耶！再玩一次！"

        ContentView.applyFeed(
            fullness: &fullness,
            happiness: &happiness,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )

        XCTAssertEqual(fullness, 100)
        XCTAssertEqual(happiness, 70)
        XCTAssertEqual(interactionCount, 2)
        XCTAssertEqual(lastAction, .playing)
        XCTAssertEqual(message, "已經吃飽啦！")
    }

    // 3. Play 正常更新三項屬性
    func testPlayUpdatesAllThreeStats() {
        var fullness = 60
        var energy = 70
        var happiness = 60
        var interactionCount = 0
        var lastAction: PetAction = .idle
        var message = "今天要一起做什麼呢？"

        ContentView.applyPlay(
            fullness: &fullness,
            energy: &energy,
            happiness: &happiness,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )

        XCTAssertEqual(fullness, 50)
        XCTAssertEqual(energy, 50)
        XCTAssertEqual(happiness, 85)
        XCTAssertEqual(interactionCount, 1)
        XCTAssertEqual(lastAction, .playing)
        XCTAssertEqual(message, "耶！再玩一次！")
    }

    // 4. Energy 過低時禁止玩耍（且優先於 Fullness 判斷）
    func testPlayRefusedWhenEnergyTooLow() {
        var fullness = 5
        var energy = 19
        var happiness = 60
        var interactionCount = 3
        var lastAction: PetAction = .idle
        var message = "今天要一起做什麼呢？"

        ContentView.applyPlay(
            fullness: &fullness,
            energy: &energy,
            happiness: &happiness,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )

        XCTAssertEqual(fullness, 5)
        XCTAssertEqual(energy, 19)
        XCTAssertEqual(happiness, 60)
        XCTAssertEqual(interactionCount, 3)
        XCTAssertEqual(lastAction, .idle)
        XCTAssertEqual(message, "我想先休息一下……")
    }

    // 5. Fullness 過低時禁止玩耍
    func testPlayRefusedWhenFullnessTooLow() {
        var fullness = 9
        var energy = 50
        var happiness = 60
        var interactionCount = 3
        var lastAction: PetAction = .idle
        var message = "今天要一起做什麼呢？"

        ContentView.applyPlay(
            fullness: &fullness,
            energy: &energy,
            happiness: &happiness,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )

        XCTAssertEqual(fullness, 9)
        XCTAssertEqual(energy, 50)
        XCTAssertEqual(happiness, 60)
        XCTAssertEqual(interactionCount, 3)
        XCTAssertEqual(lastAction, .idle)
        XCTAssertEqual(message, "肚子餓了，先吃點東西吧！")
    }

    // 6. Sleep 正常恢復 Energy（包含上限 Clamp 檢查）
    func testSleepRecoversEnergyAndClampsAtMax() {
        var fullness = 60
        var energy = 20
        var interactionCount = 1
        var lastAction: PetAction = .idle
        var message = ""

        ContentView.applySleep(
            fullness: &fullness,
            energy: &energy,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )

        XCTAssertEqual(fullness, 50)
        XCTAssertEqual(energy, 50)
        XCTAssertEqual(interactionCount, 2)
        XCTAssertEqual(lastAction, .sleeping)
        XCTAssertEqual(message, "呼嚕……晚安。")

        // 即使 energy 已達 100 仍可睡覺，但數值不超過 100
        energy = 100
        ContentView.applySleep(
            fullness: &fullness,
            energy: &energy,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )
        XCTAssertEqual(energy, 100)
        XCTAssertEqual(fullness, 40)
        XCTAssertEqual(interactionCount, 3)
    }

    // 7. Pet 正常增加 Happiness
    func testPetIncreasesHappiness() {
        var happiness = 60
        var interactionCount = 0
        var lastAction: PetAction = .idle
        var message = ""

        ContentView.applyPet(
            happiness: &happiness,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )

        XCTAssertEqual(happiness, 70)
        XCTAssertEqual(interactionCount, 1)
        XCTAssertEqual(lastAction, .petting)
        XCTAssertEqual(message, "嘿嘿，好舒服！")
    }

    // 8. Clamp 將數值限制在 0～100
    func testClampKeepsValuesWithinZeroToHundred() {
        XCTAssertEqual(ContentView.clamp(-50), 0)
        XCTAssertEqual(ContentView.clamp(0), 0)
        XCTAssertEqual(ContentView.clamp(55), 55)
        XCTAssertEqual(ContentView.clamp(100), 100)
        XCTAssertEqual(ContentView.clamp(135), 100)
    }

    // 9. Reset 恢復全部初始狀態
    func testResetRestoresInitialState() {
        var fullness = 10
        var energy = 15
        var happiness = 95
        var interactionCount = 12
        var lastAction: PetAction = .playing
        var message = "耶！再玩一次！"

        ContentView.applyReset(
            fullness: &fullness,
            energy: &energy,
            happiness: &happiness,
            interactionCount: &interactionCount,
            lastAction: &lastAction,
            message: &message
        )

        XCTAssertEqual(fullness, 60)
        XCTAssertEqual(energy, 70)
        XCTAssertEqual(happiness, 60)
        XCTAssertEqual(interactionCount, 0)
        XCTAssertEqual(lastAction, .idle)
        XCTAssertEqual(message, "今天要一起做什麼呢？")
    }

    // 10. resolvePetImageName 與 resolveStatusHint 的狀態優先順序與特殊情境
    func testResolvePetImageNameAndStatusHintPriority() {
        // 多項屬性同時 <= 20 時：hungry > sleeping > sad > lastAction
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 15, energy: 10, happiness: 10, lastAction: .playing),
            "mochi_hungry"
        )
        XCTAssertEqual(
            ContentView.resolveStatusHint(fullness: 15, energy: 10, happiness: 10, lastAction: .playing),
            "肚子咕嚕叫"
        )

        // 飢餓時按下睡覺 (fullness <= 20, lastAction == .sleeping) -> 應顯示 mochi_hungry 而非 mochi_sleeping
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 20, energy: 80, happiness: 60, lastAction: .sleeping),
            "mochi_hungry"
        )
        XCTAssertEqual(
            ContentView.resolveStatusHint(fullness: 20, energy: 80, happiness: 60, lastAction: .sleeping),
            "肚子咕嚕叫"
        )

        // 疲倦時按下摸摸 (fullness > 20, energy <= 20, lastAction == .petting) -> 應顯示 mochi_sleeping
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 50, energy: 20, happiness: 70, lastAction: .petting),
            "mochi_sleeping"
        )
        XCTAssertEqual(
            ContentView.resolveStatusHint(fullness: 50, energy: 20, happiness: 70, lastAction: .petting),
            "眼皮好沉重"
        )

        // 難過時按下餵食但快樂值仍 <= 20 (fullness > 20, energy > 20, happiness <= 20, lastAction == .eating) -> 應顯示 mochi_sad
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 65, energy: 70, happiness: 15, lastAction: .eating),
            "mochi_sad"
        )
        XCTAssertEqual(
            ContentView.resolveStatusHint(fullness: 65, energy: 70, happiness: 15, lastAction: .eating),
            "需要你陪陪"
        )

        // 一般狀態依照 lastAction 顯示對應圖片
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 60, energy: 70, happiness: 60, lastAction: .idle),
            "mochi_idle"
        )
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 85, energy: 70, happiness: 65, lastAction: .eating),
            "mochi_eating"
        )
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 50, energy: 50, happiness: 85, lastAction: .playing),
            "mochi_playing"
        )
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 50, energy: 100, happiness: 60, lastAction: .sleeping),
            "mochi_sleeping"
        )
        XCTAssertEqual(
            ContentView.resolvePetImageName(fullness: 60, energy: 70, happiness: 70, lastAction: .petting),
            "mochi_petted"
        )
    }
}

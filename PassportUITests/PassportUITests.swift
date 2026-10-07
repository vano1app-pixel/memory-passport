import XCTest

final class PassportUITests: XCTestCase {
    func testMemorySurvivesRelaunchAndExports() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Add memory"].tap()
        let editor = app.textViews["Memory text"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        let note = "QA memory " + UUID().uuidString
        editor.typeText(note)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts[note].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts[note].waitForExistence(timeout: 5))
        app.swipeUp()
        let prepare = app.buttons["Prepare AI context"]
        XCTAssertTrue(prepare.waitForExistence(timeout: 5))
        prepare.tap()
        XCTAssertTrue(app.buttons["Copy context"].waitForExistence(timeout: 5))
        app.buttons["Copy context"].tap()
        XCTAssertTrue(app.buttons["Copied"].exists)
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "Context preview"
        shot.lifetime = .keepAlways
        add(shot)
        app.buttons["Done"].tap()
        app.swipeDown()
        app.buttons["Delete"].firstMatch.tap()
        app.buttons["Delete memory"].tap()
        XCTAssertFalse(app.staticTexts[note].exists)
    }
}

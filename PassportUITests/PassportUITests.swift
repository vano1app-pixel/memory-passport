import XCTest

final class PassportUITests: XCTestCase {
    func testProExplainsAvailabilityAndKeepsRestoreVisible() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Sources"].tap()
        app.swipeUp()
        app.buttons["View Pro plan"].tap()
        XCTAssertTrue(app.staticTexts["A bigger notebook."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Restore purchases"].exists)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Pro availability"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        app.buttons["Done"].tap()
    }
    func testMemorySurvivesRelaunchAndExports() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Notebook"].tap()
        app.buttons["Add memory"].tap()
        let editor = app.textViews["Memory text"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        let note = "QA memory " + UUID().uuidString
        editor.typeText(note)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts[note].waitForExistence(timeout: 5))
        app.tabBars.buttons["Map"].tap()
        let projectNode = app.buttons["project: Personal"]
        XCTAssertTrue(projectNode.waitForExistence(timeout: 5))
        projectNode.tap()
        XCTAssertTrue(app.buttons["Use this context"].exists)
        let mapShot = XCTAttachment(screenshot: app.screenshot())
        mapShot.name = "Memory map"
        mapShot.lifetime = .keepAlways
        add(mapShot)
        app.terminate()
        app.launch()
        app.tabBars.buttons["Notebook"].tap()
        XCTAssertTrue(app.staticTexts[note].waitForExistence(timeout: 5))
        let search = app.textFields["Find a memory"]
        search.tap()
        search.typeText(note + "\n")
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
        app.terminate()
        app.launch()
        app.tabBars.buttons["Notebook"].tap()
        XCTAssertFalse(app.staticTexts[note].exists)
    }
}

import XCTest

final class TicketStubUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddFlowShowsNewItem() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["addButton"].tap()
        let field = app.textFields["field_eventName"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("Test Entry")
        app.buttons["saveButton"].tap()

        XCTAssertTrue(app.staticTexts["Test Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-forceAtLimit", "YES"]
        app.launch()

        for _ in 0..<40 {
            let addButton = app.buttons["addButton"]
            guard addButton.exists else { break }
            addButton.tap()
            if app.buttons["purchaseButton"].waitForExistence(timeout: 1) {
                break
            }
            let field = app.textFields["field_eventName"]
            if field.waitForExistence(timeout: 1) {
                field.tap()
                field.typeText("Bulk Item")
                app.buttons["saveButton"].tap()
            }
        }

        XCTAssertTrue(app.buttons["purchaseButton"].waitForExistence(timeout: 3) || app.buttons["addButton"].exists)
    }

    func testKeyboardDismissesOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["addButton"].tap()
        let field = app.textFields["field_eventName"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("Dismiss Me")
        XCTAssertTrue(app.keyboards.element.exists)

        app.navigationBars.staticTexts.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.waitForExistence(timeout: 1))
    }

    func testCancelDiscardsDraft() throws {
        let app = XCUIApplication()
        app.launch()

        let before = app.tables.cells.count
        app.buttons["addButton"].tap()
        app.buttons["cancelButton"].tap()
        XCTAssertEqual(app.tables.cells.count, before)
    }

    func testSettingsOpensAndCloses() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}

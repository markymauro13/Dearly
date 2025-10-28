//
//  CardFlipTests.swift
//  DearlyUITests
//
//  Created by Mark Mauro on 10/28/25.
//

import XCTest

final class CardFlipTests: XCTestCase {

    @MainActor
    func testCardFlip() throws {
        let app = XCUIApplication()
        app.launch()

        let card = app.otherElements["CardView"]

        let front = card.staticTexts["Front"]
        XCTAssertTrue(front.exists)

        card.tap()

        let back = card.staticTexts["Back"]
        XCTAssertTrue(back.exists)
    }
}

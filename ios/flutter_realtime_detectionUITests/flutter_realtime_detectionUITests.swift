
//
//  flutter_realtime_detectionUITests.swift
//  flutter_realtime_detectionUITests
//
//  Created by Robin Beer on 18.03.21.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

import XCTest

class flutter_realtime_detectionUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        addUIInterruptionMonitor(withDescription: "alert handler") { (alert: XCUIElement) -> Bool in
                    let confirmLabels = ["Allow", "OK", "Tillat", "Allow Once"]
                    for (_, label) in confirmLabels.enumerated() {
                        let allow = alert.buttons[label]
                        if allow.exists {
                            allow.tap()
                            break
                        }
                    }
                    return true
                }
        app.tap()
        
        sleep(10)
        
        snapshot("0-MapView")
        
        
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
        
        sleep(1)
        
        snapshot("1-PostSticker")
        
        app.buttons["Cancel"].tap()
        app.buttons["Account"].tap()
        
        sleep(1)
        
        snapshot("2-Login")
        
        app.staticTexts["Dismiss"].tap()
                
        
//        let dismissStaticText = app.staticTexts["Dismiss"]
//        dismissStaticText.tap()
//        app.buttons["Account"].tap()
//        snapshot("01Login")
//        dismissStaticText.tap()
//        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
//        snapshot("02PostSticker")
//        dismissStaticText.tap()
        

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}

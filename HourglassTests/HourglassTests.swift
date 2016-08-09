//
//  TimeBudgetTests.swift
//  TimeBudgetTests
//
//  Created by Wojciech Czekalski on 05.08.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import XCTest
@testable import TimeBudget

class TimeBudgetTests: XCTestCase {
    
    func testTimeFormatter() {
        let interval = timeInterval(from: "00:30")
        XCTAssertEqual(interval, 30*60)
        let intervalWithHours = timeInterval(from: "01:30")
        XCTAssertEqual(intervalWithHours, 1*3600+30*60)
        let invalidInterval = timeInterval(from: "a!sd:30")
        XCTAssertEqual(invalidInterval, nil)
    }
    
}

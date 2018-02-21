//
//  RepeatTests.swift
//  Repeat
//
//  Created by Daniele Margutti on 20/02/2018.
//  Copyright © 2018 Repeat. All rights reserved.
//

import Foundation
import XCTest
import Repeat

class RepeatTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(Repeat().text, "Hello, World!")
		let exp = XCTestExpectation(description: "")
		wait(for: [exp], timeout: 20)
	}
	
    static var allTests = [
        ("testExample", testExample),
    ]
}

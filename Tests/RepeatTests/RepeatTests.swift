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
		
		var c = 0
		let timer = Repeat.every( .seconds(0.5), count: 10) { _ in
			c += 1
			print("\(c)")
		}
		
		/*let timer = Repeat.after(5) { _ in
			print("bingo")
		}*/
		/*
		let timer = Repeat.every(1) { _ in
			print("1 secondo è passato")
			
		}*/
		
		
		wait(for: [exp], timeout: 20)
	}
	
    static var allTests = [
        ("testExample", testExample),
    ]
}

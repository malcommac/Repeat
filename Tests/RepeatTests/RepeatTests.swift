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
	
	private var timerInstance: Any? = nil
	
	/*func test_fireManually() {
		let exp = expectation(description: "test_infiniteReset")

		var count: Int = 0
		let t = Repeat(interval: .seconds(0.5), mode: .infinite) { t in
			print("Fired")

		}
		
		t.onStateChanged = { (_,state) in
			if state == .finished {
				exp.fullfill()
				timer.pause()
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			t.fire(andPause: true)
		}
		
		t.start()
		self.timerInstance = t
		
		wait(for: [exp], timeout: 30)
	}*/
	
	func test_pauseResetStart() {
		let exp = expectation(description: "test_infiniteReset")

		var count: Int = 0
		let timer = Repeat(interval: .seconds(0.5), mode: .infinite) { t in
		
			count += 1
			
			if count == 5 {
				t.pause()
				t.reset(.seconds(0.1), restart: true)
			} else if count == 7 {
				t.pause()
				t.start()
			} else if count == 10 {
				t.pause()
				exp.fulfill()
			}
			
		}
		timer.start()
		self.timerInstance = timer
		
		
		wait(for: [exp], timeout: 30)
	}
	
	func test_infiniteReset() {
		let exp = expectation(description: "test_infiniteReset")

		var count: Int = 0
		let timer = Repeat(interval: .seconds(0.5), mode: .infinite) { t in
			count += 1
			print("Iteration #\(count)")
			if count == 5 {
				t.reset(.seconds(0.1), restart: true)
			} else if count == 10 {
				exp.fulfill()
			}
		}
		timer.start()
		self.timerInstance = timer

		wait(for: [exp], timeout: 30)
	}
	
	func test_finiteAndRestart() {
		let exp = expectation(description: "test_finiteAndRestart")

		var count: Int = 0
		var finishedFirstTime: Bool = false
		let timer = Repeat(interval: .seconds(0.5), mode: .finite(5)) { _ in
			count += 1
			print("Iteration #\(count)")
		}
		timer.onStateChanged = { (_,state) in
			print("State changed: \(state)")
			if state.isFinished {
				if finishedFirstTime == false {
					print("Now restart")
					timer.start()
					finishedFirstTime = true
				} else {
					exp.fulfill()
				}
			}
		}
		
		timer.start()
		
		self.timerInstance = timer
		
		wait(for: [exp], timeout: 30)
	}
	
	func test_infinite() {
		let exp = expectation(description: "test_once")

		var count: Int = 0
		self.timerInstance = Repeat.every(.seconds(0.5), { _ in
			count += 1
			if count == 20 {
				exp.fulfill()
			}
		})
		
		wait(for: [exp], timeout: 10)
	}
	
	func test_once() {
		let exp = expectation(description: "test_once")
		
		self.timerInstance = Repeat.once(after: .seconds(5)) { _ in
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 6)
	}
	
	func test_onceRestart() {
		let exp = expectation(description: "test_onceRestart")
		
		var repetitions: Int = 0
		
		self.timerInstance = Repeat.once(after: .seconds(5)) { t in
			repetitions += 1
			switch repetitions {
			case 1:
				t.start()
			default:
				exp.fulfill()
			}
		}
		
		wait(for: [exp], timeout: 20)
	}
	
    static var allTests = [
        ("testExample", test_once),
    ]
}

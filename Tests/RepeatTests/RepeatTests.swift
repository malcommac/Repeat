//
//  RepeaterTests.swift
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
	private var debouncerInstance: Debouncer? = nil
	private var throttle: Throttler? = nil

	func test_throttle() {
		let exp = expectation(description: "Run once and call immediately")

		var value = 0
		self.throttle = Throttler(time: .milliseconds(500), {
			value += 1
		})
		
		self.throttle?.call()
		self.throttle?.call()
		self.throttle?.call()
		self.throttle?.call()
		self.throttle?.call()

		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
			if value == 1 {
				exp.fulfill()
			} else {
				XCTFail("Failed to throttle, calls were not ignored.")
			}
		}

		self.wait(for: [exp], timeout: 1)
	}
	
	func test_debounce_callWithoutCallback(){
		
		let d = Debouncer(.seconds(0))
		
		d.call()
		XCTAssertTrue(true)
	}
	
	func test_debounce_runOnceImmediatly(){
		let e = expectation(description: "Run once and call immediatly")
		
		let d = Debouncer(.seconds(0))
		d.callback = {
			e.fulfill()
		}
		
		d.call()
		
		self.wait(for: [e], timeout: 1)
	}
	
	func test_debounce_runThreeTimesCountTwice(){
		let e = expectation(description: "should fulfill three times")
		e.expectedFulfillmentCount = 2
		let d = Debouncer(.seconds(1))
		d.callback = {
			e.fulfill()
		}
		d.call()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
			d.call()
		})
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
			d.call()
		})
		
		// Wait timeout in seconds
		self.wait(for: [e], timeout: 2)
	}
	
	func test_debounce_runThreeTimseeCountThreeTimes(){
		let e = expectation(description: "should fulfill three times")
		e.expectedFulfillmentCount = 3
		let d = Debouncer(.seconds(1))
		d.callback = {
			e.fulfill()
		}
		d.call()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
			d.call()
		})
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
			d.call()
		})
		
		// Wait timeout in seconds
		self.wait(for: [e], timeout: 3)
	}
	
	func test_debounce_runTwiceCountTwice(){
		let e = expectation(description: "should fulfill twice")
		e.expectedFulfillmentCount = 2
		let d = Debouncer(.seconds(1))
		d.callback = {
			e.fulfill()
		}
		d.call()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
			d.call()
		})
		
		// Wait timeout in seconds
		self.wait(for: [e], timeout: 3)
	}
	
	func test_debounce_runTwiceCountOnce() {
		
		let exp = expectation(description: "should fullfile once, because calls are both runned immediatly and second one should get ignored")
		exp.expectedFulfillmentCount = 1
		
		let debouncer = Debouncer(.seconds(1), callback: {
			exp.fulfill()
		})

		debouncer.call()
		debouncer.call()
		
		self.debouncerInstance = debouncer
		wait(for: [exp], timeout: 30)
	}
	
	func test_debounce_fireManually() {
		let exp = expectation(description: "test_infiniteReset")

		let timer = Repeater(interval: .seconds(0.5), mode: .infinite) { t in
			print("Fired")
		}
		
		timer.onStateChanged = { (_,state) in
			if state == .paused {
				exp.fulfill()
				timer.pause()
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			timer.fire(andPause: true)
		}
		
		timer.start()
		self.timerInstance = timer
		
		wait(for: [exp], timeout: 30)
	}
	
	func test_timer_pauseResetStart() {
		let exp = expectation(description: "test_infiniteReset")

		var count: Int = 0
		let timer = Repeater(interval: .seconds(0.5), mode: .infinite) { t in
		
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
	
	func test_timer_infiniteReset() {
		let exp = expectation(description: "test_infiniteReset")

		var count: Int = 0
		let timer = Repeater(interval: .seconds(0.5), mode: .infinite) { t in
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
	
	func test_timer_finiteAndRestart() {
		let exp = expectation(description: "test_finiteAndRestart")

		var count: Int = 0
		var finishedFirstTime: Bool = false
		let timer = Repeater(interval: .seconds(0.5), mode: .finite(5)) { _ in
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
	
	func test_timer_infinite() {
		let exp = expectation(description: "test_once")

		var count: Int = 0
		self.timerInstance = Repeater.every(.seconds(0.5), { _ in
			count += 1
			if count == 20 {
				exp.fulfill()
			}
		})
		
		wait(for: [exp], timeout: 10)
	}
	
	func test_timer_once() {
		let exp = expectation(description: "test_once")
		
		self.timerInstance = Repeater.once(after: .seconds(5)) { _ in
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 6)
	}
	
	func test_timer_onceRestart() {
		let exp = expectation(description: "test_onceRestart")
		
		var repetitions: Int = 0
		
		self.timerInstance = Repeater.once(after: .seconds(5)) { t in
			repetitions += 1
			switch repetitions {
			case 1:
				t.reset(nil, restart: true)
			default:
				exp.fulfill()
			}
		}
		
		wait(for: [exp], timeout: 20)
	}
	
	func test_equality() {
		let repeater1 = Repeater(interval: .seconds(1)) { _ in XCTFail() }
		let repeater2 = Repeater(interval: .seconds(1)) { _ in XCTFail() }
		XCTAssertEqual(repeater1, repeater1)
		XCTAssertEqual(repeater2, repeater2)
		XCTAssertNotEqual(repeater1, repeater2)
	}
	
	static var allTests = [
		("testExample", test_once),
		("test_equality", test_equality)
	]
}

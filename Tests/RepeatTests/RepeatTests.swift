//
//  RepeaterTests.swift
//  Repeat
//
//  Created by Daniele Margutti on 20/02/2018.
//  Copyright © 2018 Repeat. All rights reserved.
//

import Foundation
import Repeat
import XCTest

class RepeatTests: XCTestCase {

	private var debouncerInstance: Debouncer?
	private var throttle: Throttler?

	func test_deinit() {
		let exp = expectation(description: "Run once and call immediately")
		exp.expectedFulfillmentCount = 1
		var testTimer: Repeater? = Repeater(interval: .seconds(1), mode: .finite(5)) { _ in

		}
		testTimer!.onStateChanged = { (_ timer: Repeater, _ state: Repeater.State) in
			if testTimer!.state.isFinished {
				testTimer = nil // this is same effect, if this in deinit
				exp.fulfill()
			}
		}
		testTimer!.start()
		self.wait(for: [exp], timeout: 10)
	}

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

	func test_debounce_callWithoutCallback() {

		let testDebouncer = Debouncer(.seconds(0))

		testDebouncer.call()
		XCTAssertTrue(true)
	}

	func test_debounce_runOnceImmediatly() {
		let exp = expectation(description: "Run once and call immediatly")

		let testDebouncer = Debouncer(.seconds(0))
		testDebouncer.callback = {
			exp.fulfill()
		}

		testDebouncer.call()

		self.wait(for: [exp], timeout: 1)
	}

	func test_debounce_runThreeTimesCountTwice() {
		let exp = expectation(description: "should fulfill three times")
		exp.expectedFulfillmentCount = 3

		let testDebouncer = Debouncer(.seconds(0.5))
		testDebouncer.callback = {
			exp.fulfill()
		}
		testDebouncer.call()

		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
			testDebouncer.call()
		})
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
			testDebouncer.call()
		})

		// Wait timeout in seconds
		self.wait(for: [exp], timeout: 20)
	}

	func test_debounce_runTwiceCountTwice() {
		let exp = expectation(description: "should fulfill twice")
		exp.expectedFulfillmentCount = 2

		let testDebouncer = Debouncer(.seconds(1))
		testDebouncer.callback = {
			exp.fulfill()
		}
		testDebouncer.call()

		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
			testDebouncer.call()
		})

		// Wait timeout in seconds
		self.wait(for: [exp], timeout: 3)
	}

	func test_debounce_runTwiceCountOnce() {

		let exp = expectation(description: "should fullfile once, because calls are both runned immediatly and second one should get ignored")
		exp.expectedFulfillmentCount = 1

		let debouncer = Debouncer(.seconds(3), callback: {
			exp.fulfill()
		})

		debouncer.call()
		debouncer.call()

		self.debouncerInstance = debouncer
		wait(for: [exp], timeout: 30)
	}

	func test_debounce_fireManually() {
		let exp = expectation(description: "test_infiniteReset")

		let timer = Repeater(interval: .seconds(0.5), mode: .infinite) { _ in
			print("Fired")
		}

		timer.onStateChanged = { (_, state) in
			if state == .paused {
				exp.fulfill()
				timer.pause()
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			timer.fire(andPause: true)
		}

		timer.start()

		wait(for: [exp], timeout: 30)
	}

	func test_timer_pauseResetStart() {
		let exp = expectation(description: "test_infiniteReset")

		var count: Int = 0
		let timer = Repeater(interval: .seconds(0.5), mode: .infinite) { tmr in

			count += 1

			if count == 5 {
				tmr.pause()
				tmr.reset(.seconds(0.1), restart: true)
			} else if count == 7 {
				tmr.pause()
				tmr.start()
			} else if count == 10 {
				tmr.pause()
				exp.fulfill()
			}

		}
		timer.start()

		wait(for: [exp], timeout: 30)
	}

	func test_timer_infiniteReset() {
		let exp = expectation(description: "test_infiniteReset")

		var count: Int = 0
		let timer = Repeater(interval: .seconds(0.5), mode: .infinite) { tmr in
			count += 1
			print("Iteration #\(count)")
			if count == 5 {
				tmr.reset(.seconds(0.1), restart: true)
			} else if count == 10 {
				exp.fulfill()
			}
		}
		timer.start()

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
		timer.onStateChanged = { (_, state) in
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

		wait(for: [exp], timeout: 30)
	}

	func test_timer_infinite() {
		let exp = expectation(description: "test_once")

		var count: Int = 0
		let timer = Repeater.every(.seconds(0.5), { _ in
			count += 1
			if count == 20 {
				exp.fulfill()
			}
		})

		print("Allocated timer \(timer)")
		wait(for: [exp], timeout: 10)
	}

	func test_timer_once() {
		let exp = expectation(description: "test_once")

		let timer = Repeater.once(after: .seconds(5)) { _ in
			exp.fulfill()
		}

		print("Allocated timer \(timer)")
		wait(for: [exp], timeout: 6)
	}

	func test_equality() {
		let repeater1 = Repeater(interval: .seconds(1)) { _ in XCTFail() }
		let repeater2 = Repeater(interval: .seconds(1)) { _ in XCTFail() }
		XCTAssertEqual(repeater1, repeater1)
		XCTAssertEqual(repeater2, repeater2)
		XCTAssertNotEqual(repeater1, repeater2)
	}

	func test_timer_onceRestart() {
		let exp = expectation(description: "test_onceRestart")

		var repetitions: Int = 0

		let timer = Repeater.once(after: .seconds(5)) { tmr in
			repetitions += 1
			switch repetitions {
			case 1:
				tmr.reset(.seconds(1), restart: true)
			default:
				exp.fulfill()
			}
		}

		print("Allocated timer \(timer)")
		wait(for: [exp], timeout: 20)
	}

}

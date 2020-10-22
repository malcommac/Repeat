//
//	Repeat
//	A modern alternative to NSTimer made in GCD with debouncer and throttle
//	-----------------------------------------------------------------------
//	Created by:	Daniele Margutti
//				hello@danielemargutti.com
//				http://www.danielemargutti.com
//
//	Twitter:	@danielemargutti
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation

open class Repeater: Equatable {

	/// State of the timer
	///
	/// - paused: idle (never started yet or paused)
	/// - running: timer is running
	/// - executing: the observers are being executed
	/// - finished: timer lifetime is finished
    public enum State: String, Equatable, CustomStringConvertible {
        case paused = "idle/paused"
		case running
		case executing
		case finished

		/// Return `true` if timer is currently running, including when the observers are being executed.
		public var isRunning: Bool {
            self == .running || self == .executing
		}

		/// Return `true` if the observers are being executed.
		public var isExecuting: Bool {
            self == .executing
		}

		/// Is timer finished its lifetime?
		/// It return always `false` for infinite timers.
		/// It return `true` for `.once` mode timer after the first fire,
		/// and when `.remainingIterations` is zero for `.finite` mode timers
		public var isFinished: Bool {
            self == .finished
		}

		/// State description
        public var description: String {
            rawValue
        }
	}

	/// Repeat interval
	public enum Interval {
        case nanoseconds(Int)
        case microseconds(Int)
        case milliseconds(Int)
        case minutes(Int)
        case seconds(Double)
        case hours(Int)
        case days(Int)

		internal var value: DispatchTimeInterval {
			switch self {
			case .nanoseconds(let value):		return .nanoseconds(value)
			case .microseconds(let value):		return .microseconds(value)
			case .milliseconds(let value):		return .milliseconds(value)
			case .seconds(let value):			return .milliseconds(Int( Double(value) * Double(1000)))
			case .minutes(let value):			return .seconds(value * 60)
			case .hours(let value):				return .seconds(value * 3600)
			case .days(let value):				return .seconds(value * 86400)
			}
		}
	}

	/// Mode of the timer.
	///
	/// - infinite: infinite number of repeats.
	/// - finite: finite number of repeats.
	/// - once: single repeat.
    public enum Mode: Equatable {
		case infinite
		case finite(Int)
		case once

		/// Is timer a repeating timer?
		internal var isRepeating: Bool {
            self != .once
		}

		/// Number of repeats, if applicable. Otherwise `nil`
		public var countIterations: Int? {
            if case .finite(let counts) = self {
                return counts
            }
            return nil
		}

		/// Is infinite timer
        public var isInfinite: Bool {
            self == .infinite
        }
	}

	/// Handler typealias
	public typealias Observer = ((Repeater) -> Void)

	/// Token assigned to the observer
	public typealias ObserverToken = UInt64

	/// Current state of the timer
	public private(set) var state: State = .paused {
		didSet {
            onStateChanged?(self, state)
		}
	}

	/// Callback called to intercept state's change of the timer
	public var onStateChanged: ((_ timer: Repeater, _ state: State) -> Void)?

	/// List of the observer of the timer
	private var observers = [ObserverToken: Observer]()

	/// Next token of the timer
	private var nextObserverID: UInt64 = 0

	/// Internal GCD Timer
	private var timer: DispatchSourceTimer?

	/// Is timer a repeat timer
	public private(set) var mode: Mode

	/// Number of remaining repeats count
	public private(set) var remainingIterations: Int?

	/// Interval of the timer
	private var interval: Interval

	/// Accuracy of the timer
	private var tolerance: DispatchTimeInterval

	/// Dispatch queue parent of the timer
	private var queue: DispatchQueue?

	/// Initialize a new timer.
	///
	/// - Parameters:
	///   - interval: interval of the timer
	///   - mode: mode of the timer
	///   - tolerance: tolerance of the timer, 0 is default.
	///   - queue: queue in which the timer should be executed; if `nil` a new queue is created automatically.
	///   - observer: observer
    public init(
        interval: Interval,
        mode: Mode = .infinite,
        tolerance: DispatchTimeInterval = .nanoseconds(0),
        queue: DispatchQueue? = nil,
        observer: @escaping Observer
    ) {
		self.mode = mode
		self.interval = interval
		self.tolerance = tolerance
		self.remainingIterations = mode.countIterations
		self.queue = (queue ?? DispatchQueue(label: "com.repeat.queue"))
		self.timer = configureTimer()
		self.observe(observer)
	}

	/// Add new a listener to the timer.
	///
	/// - Parameter callback: callback to call for fire events.
	/// - Returns: token used to remove the handler
	@discardableResult
	public func observe(_ observer: @escaping Observer) -> ObserverToken {
		var (new, overflow) = nextObserverID.addingReportingOverflow(1)
		if overflow { // you need to add an incredible number of offset...sure you can't
			nextObserverID = 0
			new = 0
		}
        nextObserverID = new
        observers[new] = observer
		return new
	}

	/// Remove an observer of the timer.
	///
	/// - Parameter id: id of the observer to remove
	public func remove(observer identifier: ObserverToken) {
		observers.removeValue(forKey: identifier)
	}

	/// Remove all observers of the timer.
	///
	/// - Parameter stopTimer: `true` to also stop timer by calling `pause()` function.
	public func removeAllObservers(thenStop stopTimer: Bool = false) {
		observers.removeAll()

		if stopTimer {
			pause()
		}
	}

	/// Configure a new timer session.
	///
	/// - Returns: dispatch timer
	private func configureTimer() -> DispatchSourceTimer {

        let timer = DispatchSource.makeTimerSource(
            queue: queue ?? DispatchQueue(
                label: "com.repeat.\(NSUUID().uuidString)"
            )
        )

        timer.schedule(
            deadline: .now() + interval.value,
            repeating: mode.isRepeating ? interval.value : .never,
            leeway: tolerance
        )

		timer.setEventHandler { [weak self] in
			if let unwrapped = self {
				unwrapped.timeFired()
			}
		}
		return timer
	}

	/// Destroy current timer
	private func destroyTimer() {
        timer?.setEventHandler(handler: nil)
        timer?.cancel()

		if state == .paused || state == .finished {
            timer?.resume()
		}
	}

	/// Create and schedule a timer that will call `handler` once after the specified time.
	///
	/// - Parameters:
	///   - interval: interval delay for single fire
	///   - queue: destination queue, if `nil` a new `DispatchQueue` is created automatically.
	///   - observer: handler to call when timer fires.
	/// - Returns: timer instance
	@discardableResult
    public class func once(
        after interval: Interval,
        tolerance: DispatchTimeInterval = .nanoseconds(0),
        queue: DispatchQueue? = nil,
        _ observer: @escaping Observer
    ) -> Repeater {
        let timer = Repeater(
            interval: interval,
            mode: .once,
            tolerance: tolerance,
            queue: queue,
            observer: observer
        )
		timer.start()
		return timer
	}

	/// Create and schedule a timer that will fire every interval optionally by limiting the number of fires.
	///
	/// - Parameters:
	///   - interval: interval of fire
	///   - count: a non `nil` and > 0  value to limit the number of fire, `nil` to set it as infinite.
	///   - queue: destination queue, if `nil` a new `DispatchQueue` is created automatically.
	///   - handler: handler to call on fire
	/// - Returns: timer
	@discardableResult
    public class func every(
        _ interval: Interval,
        count: Int? = nil,
        tolerance: DispatchTimeInterval = .nanoseconds(0),
        queue: DispatchQueue? = nil,
        _ handler: @escaping Observer
    ) -> Repeater {
        let timer = Repeater(
            interval: interval,
            mode: count != nil ? .finite(count!) : .infinite,
            tolerance: tolerance,
            queue: queue,
            observer: handler
        )
		timer.start()
		return timer
	}

	/// Force fire.
	///
	/// - Parameter pause: `true` to pause after fire, `false` to continue the regular firing schedule.
	public func fire(andPause pause: Bool = false) {
        timeFired()
        if pause {
            self.pause()
		}
	}

	/// Reset the state of the timer, optionally changing the fire interval.
	///
	/// - Parameters:
	///   - interval: new fire interval; pass `nil` to keep the latest interval set.
	///   - restart: `true` to automatically restart the timer, `false` to keep it stopped after configuration.
    public func reset(
        _ interval: Interval?,
        restart: Bool = true
    ) {
        if state.isRunning {
            setPause(from: state)
		}

		// For finite counter we want to also reset the repeat count
		if case .finite(let count) = self.mode {
            remainingIterations = count
		}

		// Create a new instance of timer configured
		if let newInterval = interval {
			self.interval = newInterval
		} // update interval
        destroyTimer()
        timer = configureTimer()
        state = .paused

		if restart {
            timer?.resume()
            state = .running
		}
	}

	/// Start timer. If timer is already running it does nothing.
	@discardableResult
	public func start() -> Bool {
        guard !state.isRunning else {
			return false
		}

		// If timer has not finished its lifetime we want simply
		// restart it from the current state.
        guard state.isFinished else {
            state = .running
            timer?.resume()
			return true
		}

		// Otherwise we need to reset the state based upon the mode
		// and start it again.
        reset(nil, restart: true)
		return true
	}

	/// Pause a running timer. If timer is paused it does nothing.
	@discardableResult
	public func pause() -> Bool {
		guard state != .paused && state != .finished else {
			return false
		}

		return setPause(from: self.state)
	}

	/// Pause a running timer optionally changing the state with regard to the current state.
	///
	/// - Parameters:
	///   - from: the state which the timer should only be paused if it is the current state
	///   - to: the new state to change to if the timer is paused
	/// - Returns: `true` if timer is paused
	@discardableResult
	private func setPause(from currentState: State, to newState: State = .paused) -> Bool {
        guard state == currentState else {
			return false
		}

        timer?.suspend()
        state = newState

		return true
	}

	/// Called when timer is fired
	private func timeFired() {
        state = .executing

        if case .finite = mode {
            remainingIterations! -= 1
		}

		// dispatch to observers
        observers.values.forEach { $0(self) }

		// manage lifetime
		switch mode {
		case .once:
			// once timer's lifetime is finished after the first fire
			// you can reset it by calling `reset()` function.
            setPause(from: .executing, to: .finished)
		case .finite:
			// for finite intervals we decrement the left iterations count...
            if remainingIterations! == 0 {
				// ...if left count is zero we just pause the timer and stop
                setPause(from: .executing, to: .finished)
			}
		case .infinite:
			// infinite timer does nothing special on the state machine
			break
		}

	}

	deinit {
        observers.removeAll()
        destroyTimer()
	}

	public static func == (lhs: Repeater, rhs: Repeater) -> Bool {
        lhs === rhs
	}
}

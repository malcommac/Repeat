//
//	Repeat
//	A modern alternative to NSTimer
//	------------------------------------------------
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

open class Repeat : Equatable {
	
	/// Repeat interval
	public enum Interval {
		case nanoseconds(_: Int)
		case microseconds(_: Int)
		case milliseconds(_: Int)
		case seconds(_: Double)
		case hours(_: Int)
		case days(_: Int)
		
		internal var value: DispatchTimeInterval {
			switch self {
			case .nanoseconds(let v):		return .nanoseconds(v)
			case .microseconds(let v):		return .microseconds(v)
			case .milliseconds(let v):		return .milliseconds(v)
			case .seconds(let v):			return .milliseconds(Int( Double(v) * Double(1000)))
			case .hours(let v):				return .seconds(v * 3600)
			case .days(let v):				return .seconds(v * 86400)
			}
		}
	}
	
	/// Mode of the timer.
	///
	/// - infinite: infinite number of repeats.
	/// - finite: finite number of repeats.
	/// - once: single repeat.
	public enum Mode {
		case infinite
		case finite(_: Int)
		case once
		
		/// Is timer a repeating timer?
		internal var isRepeating: Bool {
			switch self {
			case .once: return false
			default:	return true
			}
		}
		
		/// Number of repeats, if applicable. Otherwise `nil`
		public var repeatCount: Int? {
			switch self {
			case .finite(let c):	return c
			default:				return nil
			}
		}
		
	}
	
	/// Handler typealias
	public typealias Observer = ((Repeat) -> (Void))
	
	/// Token assigned to the observer
	public typealias ObserverToken = UInt64

	/// List of the observer of the timer
	private var observers = [ObserverToken : Observer]()

	/// Next token of the timer
	private var nextObserverID: UInt64 = 0
	
	/// Internal GCD Timer
	private var timer: DispatchSourceTimer!
	
	/// Is timer a repeat timer
	private var mode: Mode
	
	/// Number of remaining repeats count
	private var countRemainingRepeat: Int?
	
	/// Is timer currently running
	private var isRunning: Bool = false
	
	/// Interval of the timer
	private var interval: Interval
	
	/// Accuracy of the timer
	private var torelance: DispatchTimeInterval
	
	/// Dispatch queue parent of the timer
	private var queue: DispatchQueue? = nil
	
	/// Unique identifier
	public let id: UUID = UUID()
	
	/// Initialize a new timer.
	///
	/// - Parameters:
	///   - interval: interval of the timer
	///   - mode: mode of the timer
	///   - torelance: tolerance of the timer, 0 is default.
	///   - queue: queue in which the timer should be executed; if `nil` a new queue is created automatically.
	///   - observer: observer
	public init(interval: Interval, mode: Mode = .infinite,
				torelance: DispatchTimeInterval = .nanoseconds(0),
				queue: DispatchQueue? = nil,
				observer: @escaping  Observer) {
		self.mode = mode
		self.interval = interval
		self.torelance = torelance
		self.countRemainingRepeat = mode.repeatCount
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
		var (new,overflow) = self.nextObserverID.addingReportingOverflow(1)
		if overflow { // you need to add an incredible number of offset...sure you can't
			self.nextObserverID = 0
			new = 0
		}
		self.observers[new] = observer
		return new
	}
	
	/// Remove an observer of the timer.
	///
	/// - Parameter id: id of the observer to remove
	public func remove(observer id: ObserverToken) {
		self.observers.removeValue(forKey: id)
	}
	
	/// Remove all observers of the timer.
	public func removeAllObservers() {
		self.observers.removeAll()
	}
	
	/// Configure a new timer session.
	///
	/// - Returns: dispatch timer
	private func configureTimer() -> DispatchSourceTimer {
		let timer = DispatchSource.makeTimerSource(queue: (queue ?? DispatchQueue(label: "com.repeat.queue")))
		let repatInterval = interval.value
		let deadline: DispatchTime = (DispatchTime.now() + repatInterval)
		if self.mode.isRepeating {
			timer.schedule(deadline: deadline, repeating: repatInterval, leeway: torelance)
		} else {
			timer.schedule(deadline: deadline, leeway: torelance)
		}
		
		timer.setEventHandler { [weak self] in
			if let unwrapped = self {
				unwrapped.timeFired()
			}
		}
		return timer
	}
	
	
	/// Create and schedule a timer that will call `handler` once after the specified time.
	///
	/// - Parameters:
	///   - interval: interval delay for single fire
	///   - handler: handler to call
	/// - Returns: created timer
	@discardableResult
	public class func once(after interval: Interval, _ observer: @escaping Observer) -> Repeat {
		let timer = Repeat(interval: interval, mode: .once, observer: observer)
		timer.start()
		return timer
	}
	
	/// Create and schedule a timer that will fire every interval optionally by limiting the number of fires.
	///
	/// - Parameters:
	///   - interval: interval of fire
	///   - count: a non `nil` and > 0  value to limit the number of fire, `nil` to set it as infinite.
	///   - handler: handler to call on fire
	/// - Returns: timer
	@discardableResult
	public class func every(_ interval: Interval, count: Int? = nil, _ handler: @escaping Observer) -> Repeat {
		let mode: Mode = (count != nil ? .finite(count!) : .infinite)
		let timer = Repeat(interval: interval, mode: mode, observer: handler)
		timer.start()
		return timer
	}
	
	/// Force fire.
	///
	/// - Parameter pause: `true` to pause after fire, `false` to continue the regular firing schedule.
	public func fire(andPause pause: Bool = false) {
		self.timeFired()
		if pause == true {
			self.pause()
		}
	}
	
	/// Reset to a new specified interval.
	/// If timer is with a limit count it will be resetted to the intial value automatically.
	///
	/// - Parameter timeout: interval of the timer
	public func reset(_ interval: Interval?) {
		guard self.isRunning else { return }
		self.pause()
		if let i = interval {
			self.interval = i
			self.countRemainingRepeat = self.mode.repeatCount
		}
		self.timer = configureTimer()
		self.start()
	}
	
	/// Start timer. If timer is already running it does nothing.
	@discardableResult
	public func start() -> Bool {
		guard self.isRunning == false else { return false }
		self.timer.resume()
		self.isRunning = true
		return true
	}
	
	/// Pause a running timer. If timer is paused it does nothing.
	@discardableResult
	public func pause() -> Bool {
		guard self.isRunning else { return false }
		self.timer.suspend()
		self.isRunning = false
		return true
	}
	
	/// Called when timer is fired
	private func timeFired() {
		self.observers.values.forEach {
			$0(self)
		}
		
		func decrementRepeatCountIfNeeded() {
			guard self.mode.isRepeating, self.mode.repeatCount ?? 0 > 0 else { return }
			self.countRemainingRepeat! -= 1
			if self.countRemainingRepeat! == 0 {
				self.pause()
			}
		}
		
		decrementRepeatCountIfNeeded()
	}
	
	deinit {
		self.observers.removeAll()
		self.timer.cancel()
		// If the timer is suspended, calling cancel without resuming
		// triggers a crash. This is documented here
		// https://forums.developer.apple.com/thread/15902
		self.start()
	}
	
	public static func == (lhs: Repeat, rhs: Repeat) -> Bool {
		return (lhs.id == rhs.id)
	}
}

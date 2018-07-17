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

/// The Debouncer will delay a function call, and every time it's getting called it will
/// delay the preceding call until the delay time is over.
open class Debouncer {

	/// Typealias for callback type
	public typealias Callback = (() -> Void)

	/// Delay interval
	private (set) public var delay: Repeater.Interval

	/// Callback to activate
	public var callback: Callback?

	/// Internal timer to fire callback event.
	private var timer: Repeater?

	/// Initialize a new debouncer with given delay and callback.
	/// Debouncer class to delay functions that only get delay each other until the timer fires.
	///
	/// - Parameters:
	///   - delay: delay interval
	///   - callback: callback to activate
	public init(_ delay: Repeater.Interval, callback: Callback? = nil) {
		self.delay = delay
		self.callback = callback
	}

	/// Call debouncer to start the callback after the delayed time.
	/// Multiple calls will ignore the older calls and overwrite the firing time.
    ///
    /// - Parameters:
    ///   - newDelay: New delay interval
    public func call(newDelay: Repeater.Interval? = nil) {

        if let newDelay = newDelay {
            self.delay = newDelay
        }

		if self.timer == nil {
			self.timer = Repeater.once(after: self.delay, { [weak self] _ in
				guard let callback = self?.callback else {
					debugPrint("Debouncer fired but callback not set.")
					return
				}
				callback()
			})
		} else {
			self.timer?.reset(self.delay, restart: true)
		}
	}
}

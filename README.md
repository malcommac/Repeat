# Repeat - modern NSTimer in GCD, debouncer and throttler

[![Version](https://img.shields.io/cocoapods/v/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat) [![License](https://img.shields.io/cocoapods/l/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat) [![Platform](https://img.shields.io/cocoapods/p/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Repeat.svg)](https://img.shields.io/cocoapods/v/Repeat.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@danielemargutti-blue.svg?style=flat)](http://twitter.com/danielemargutti)

<p align="center" >★★ <b>Star me to follow the project! </b> ★★<br>
Created by <b>Daniele Margutti</b> - <a href="http://www.danielemargutti.com">danielemargutti.com</a>
</p>


Repeat is small lightweight alternative to `NSTimer` with a modern Swift Syntax, no strong references, multiple observers reusable instances.
Repeat is based upon GCD - Grand Central Dispatch. 
It also support debouncer and throttler features.

## A deep look at Timers

If you want to learn more about it check out my article on Medium: [**"The secret world of NSTimer"**](https://medium.com/@danielemargutti/the-secret-world-of-nstimer-708f508c9eb).

## Features Highlights

Main features offered by Repeat are:

* **Simple, less verbose APIs** methods to create and manage our timer. Just call `every()` or `once` to create a new Timer even in background thread.
* **Avoid strong references** to the destination target and avoid NSObject inheritance.
* Support **multiple observers** to receive fire events from timer.
* Ability to **pause , start , resume and reset** our timer without allocating a new instance.
* Ability to set **different repeat modes** (`infinite` : infinite sequence of fires, at regular intervals, `finite` : a finite sequence of fires, at regular intervals, `once` : a single fire events at specified interval since start).

Moreover Repeat also provide supports for:

* **Debouncer**: Debouncer will delay a function call, and every time it's getting called it will delay the preceding call until the delay time is over.
* **Throttler**: Throttling wraps a block of code with throttling logic, guaranteeing that an action will never be called more than once each specified interval.

## Other Libraries You May Like

I'm also working on several other projects you may like.
Take a look below:

<p align="center" >

| Library         | Description                                      |
|-----------------|--------------------------------------------------|
| [**SwiftDate**](https://github.com/malcommac/SwiftDate)       | The best way to manage date/timezones in Swift   |
| [**Hydra**](https://github.com/malcommac/Hydra)           | Write better async code: async/await & promises  |
| [**Flow**](https://github.com/malcommac/Flow) | A new declarative approach to table managment. Forget datasource & delegates. |
| [**SwiftRichString**](https://github.com/malcommac/SwiftRichString) | Elegant & Painless NSAttributedString in Swift   |
| [**SwiftLocation**](https://github.com/malcommac/SwiftLocation)   | Efficient location manager                       |
| [**SwiftMsgPack**](https://github.com/malcommac/SwiftMsgPack)    | Fast/efficient msgPack encoder/decoder           |
</p>

## Documentation
* [Timer](#timer)
* [Debouncer](#debouncer)
* [Throttler](#throttler)

<a name="timer"/>

### Timer

**Note**: As any other object `Repeater` class is subject to the standard memory management rules. So once you create your timer instance you need to retain it somewhere in order to avoid premature deallocation just after the start command.

#### Create single fire timer

The following code create a timer which fires a single time after 5 seconds.

```swift
self.timer = Repeater.once(after: .seconds(5)) { timer in
  // do something	
}
```

#### Create recurrent finite timer

The following code create a recurrent timer: it will fire every 10 minutes for 5 times, then stops.

```swift
self.timer = Repeater.every(.minutes(10), count: 5) { timer  in
  // do something		
}
```

#### Create recurrent infinite timer

The following code create a recurrent timer which fires every hour until it is manually stopped .

```swift
self.timer = Repeater.every(.hours(1)) { timer in
  // do something
}
```

#### Manage a timer

You can create a new instance of timer and start as needed by calling the `start()` function.

```swift
self.timer = Repeater(interval: .seconds(5), mode: .infinite) { _ in
  // do something		
}
timer.start()
```

Other functions are:

* `start()`: start a paused or newly created timer
* `pause()`: pause a running timer
* `reset(_ interval: Interval, restart: Bool)`: reset a running timer, change the interval and restart again if set.
* `fire()`: manually fire an event of the timer from an external source

Properties:

* `.id`: unique identifier of the timer
* `.mode`: define the type of timer (`infinite`,`finite`,`once`)
* `.remainingIterations`: for a `.finite` mode it contains the remaining number of iterations before it finishes.

#### Adding/Removing Observers

By default a new timer has a single observer specified by the init functions. You can, however, create additional observer by using `observe()` function. The result of this call is a token identifier you can use to remove the observer in a second time.
Timer instance received in callback is weak.

```swift
let token = timer.observe { _ in
  // a new observer is called		
}
timer.start()
```

You can remove an observer by using the token:

```swift 
timer.remove(token)
```

#### Observing state change

Each timer can be in one of the following states, you can observe via `.state` property:

* `.paused`: timer is in idle (never started yet) or paused
* `.running`: timer is currently active and running
* `.executing`: registered observers are being executed
* `.finished`: timer lifecycle is finished (it's valid for a finite/once state timer)

You can listen for state change by assigning a function callback for `.onStateChanged` property.

```swift
timer.onStateChanged = { (timer,newState) in
	// your own code
}
```
<a name="debouncer"/>

### Debouncer

Since 0.5 Repeater introduced `Debouncer` class.
The Debouncer will delay a function call, and every time it's getting called it will delay the preceding call until the delay time is over.

The debounce function is an extremely useful tool that can help throttle requests.
It is different to throttle though as throttle will allow only one request per time period, debounce will not fire immediately and wait the specified time period before firing the request.
If there is another request made before the end of the time period then we restart the count. This can be extremely useful for calling functions that often get called and are only needed to run once after all the changes have been made.

```swift
let debouncer = Debouncer(.seconds(10))
debouncer.callback = {
	// your code here
}

// Call debouncer to start the callback after the delayed time.
// Multiple calls will ignore the older calls and overwrite the firing time.
debouncer.call()
```

(Make sure to check out the Unit Tests for further code samples.)

<a name="throttler"/>

### Throttler

Since 0.5 Repeater introduced `Throttler` class.

Throttling wraps a block of code with throttling logic, guaranteeing that an action will never be called more than once each specified interval. Only the last dispatched code-block will be executed when delay has passed.

```swift
let throttler = Throttler(time: .milliseconds(500), {
  // your code here
})

// Call throttler. Defined block will never be called more than once each specified interval.
throttler.call()
```

## Requirements

Repeat is compatible with Swift 4.x.
All Apple platforms are supported:

* iOS 8.0+
* macOS 10.10+
* watchOS 2.0+
* tvOS 9.0+

## Latest Version

Latest version of Repeat is [0.5.4](https://github.com/malcommac/Repeat/releases/tag/0.5.4) published on 2018/04/28.
Full changelog is available in [CHANGELOG.md](CHANGELOG.md) file.

## Installation

<a name="cocoapods" />

### Install via CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like Repeat in your projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
```

> CocoaPods 1.0.1+ is required to build Repeat.

#### Install via Podfile

To integrate Repeat into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
use_frameworks!
pod 'Repeat'
end
```

Then, run the following command:

```bash
$ pod install
```

<a name="carthage" />

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Repeat into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "malcommac/Repeat"
```

Run `carthage` to build the framework and drag the built `Repeat.framework` into your Xcode project.



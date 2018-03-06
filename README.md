# Repeat: modern NSTimer in GCD

[![Version](https://img.shields.io/cocoapods/v/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat) [![License](https://img.shields.io/cocoapods/l/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat) [![Platform](https://img.shields.io/cocoapods/p/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Repeat.svg)](https://img.shields.io/cocoapods/v/Repeat.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@danielemargutti-blue.svg?style=flat)](http://twitter.com/danielemargutti)

<p align="center" >★★ <b>Star me to follow the project! </b> ★★</p>

Repeat is small lightweight alternative to `NSTimer` with a modern Swift Syntax, no strong references, multiple observers reusable instances.
Repeat is based upon GCD - Grand Central Dispatch. 

**› Learn More**: If you want to learn more about it check out [my article on Medium](https://medium.com/@danielemargutti/the-secret-world-of-nstimer-708f508c9eb).

Main features offered by Repeat are:

* Simple, less verbose APIs methods to create and manage our timer. Just call `every()` or `once` to create a new Timer even in background thread.
* Avoid strong reference to the destination target and avoid NSObject inheritance.
* Support multiple observers to receive fire events from timer.
* Ability to pause , start , resume and reset our timer without allocating a new instance.
* Ability to set different repeat modes (`infinite` : infinite sequence of fires, at regular intervals, `finite` : a finite sequence of fires, at regular intervals, `once` : a single fire events at specified interval since start).

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

## Examples

### Create single fire timer

The following code create a timer which fires a single time after 5 seconds.

```swift
Repeater.once(after: .seconds(5)) { timer in
  // do something	
}
```

### Create recurrent finite timer

The following code create a recurrent timer: it will fire every 10 minutes for 5 times, then stops.

```swift
Repeater.every(.minutes(10), count: 5) { timer  in
  // do something		
}
```

### Create recurrent infinite timer

The following code create a recurrent timer which fires every hour until it is manually stopped .

```swift
Repeater.every(.hours(1)) { timer in
  // do something
}
```

### Manage a timer

You can create a new instance of timer and start as needed by calling the `start()` function.

```swift
let timer = Repeater(interval: .seconds(5), mode: .infinite) { _ in
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

### Adding/Removing Observers

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

### Observing state change

Each timer can be in one of the following states, you can observe via `.state` property:

* `.paused`: timer is in idle (never started yet) or paused
* `.running`: timer is currently active and running
* `.finished`: timer lifecycle is finished (it's valid for a finite/once state timer)

You can listen for state change by assigning a function callback for `.onStateChanged` property.

```swift
timer.onStateChanged = { (timer,newState) in
	// your own code
}
```

## Requirements

Repeat is compatible with Swift 4.x.
All Apple platforms are supported:

* iOS 8.0+
* macOS 10.9+
* watchOS 2.0+
* tvOS 9.0+

## Latest Version

Latest version of Repeat is [0.3.1](https://github.com/malcommac/Repeat/releases/tag/0.3.1) published on 2018/03/06.

**Changelog - 0.3.1**:

* [#8](https://github.com/malcommac/Repeat/issues/8): Disabled Gather Coverage Data to enable successfully Carthage builds.

**Changelog - 0.3.0**:

* [#7](https://github.com/malcommac/Repeat/issues/7): Renamed `Repeat` in `Repeater` in order to avoid collision with `Swift.Repeat`.

**Changelog - 0.2.1**:

* [#6](https://github.com/malcommac/Repeat/issues/6): Fixed crash on `deinit()` a running timer.

**Changelog - 0.2.0**:

* [#1](https://github.com/malcommac/Repeat/issues/3): Fixed CocoaPods installation
* [#2](https://github.com/malcommac/Repeat/issues/2): Fixed leaks with GCD while deallocating dispatch queue
* [#3](https://github.com/malcommac/Repeat/issues/3): Refactoring timer's state using a `State` enum which define the possible states of the timer (`paused`,`running` or `finished`).

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



# New Document# Repeat

[![Version](https://img.shields.io/cocoapods/v/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat) [![License](https://img.shields.io/cocoapods/l/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat) [![Platform](https://img.shields.io/cocoapods/p/Repeat.svg?style=flat)](http://cocoadocs.org/docsets/Repeat)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Repeat.svg)](https://img.shields.io/cocoapods/v/Repeat.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@danielemargutti-blue.svg?style=flat)](http://twitter.com/danielemargutti)

<p align="center" >★★ <b>Star Repeat to help the project! </b> ★★</p>

# Modern NSTimer in GCD

Repeat is small lightweight alternative to `NSTimer` with a modern Swift Syntax, no strong references, multiple observers reusable instances.
Repeat is based upon GCD - Grand Central Dispatch. If you want to learn more about it check out [my article](https://medium.com/@danielemargutti/the-secret-world-of-nstimer-708f508c9eb) on Medium.

Main features offered by Repeat are:

* Simple, less verbose APIs methods to create and manage our timer. Just call `every()` or `once` to create a new Timer even in background thread.
* Avoid strong reference to the destination target and avoid NSObject inheritance.
* Support multiple observers to receive fire events from timer.
* Ability to pause , start , resume and reset our timer without allocating a new instance.
* Ability to set different repeat modes (`infinite` : infinite sequence of fires, at regular intervals, `finite` : a finite sequence of fires, at regular intervals, `once` : a single fire events at specified interval since start).

## Examples

### Create single fire timer

The following code create a timer which fires a single time after 5 seconds.

```swift
Repeat.once(after: .seconds(5)) { timer in
  // do something	
}
```

### Create recurrent finite timer

The following code create a recurrent timer: it will fire every 10 minutes for 5 times, then stops.

```swift
Repeat.every(.minutes(10), count: 5) { timer  in
  // do something		
}
```

### Create recurrent infinite timer

The following code create a recurrent timer which fires every hour until it is manually stopped .

```swift
Repeat.every(.hours(1)) { timer in
  // do something
}
```

### Manage a timer

You can create a new instance of timer and start as needed by calling the `start()` function.

```swift
let timer = Repeat(interval: .seconds(5), mode: .infinite) { _ in
	// do something		
}
timer.start()
```

Other functions are:

* `start()`: start a paused or newly created timer
* `pause()`: pause a running timer
* `reset(_ interval: Interval)`: reset a running timer, change the interval and restart again
* `fire()`: manually fire an event of the timer from an external source

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
``


## Installation

<a name="cocoapods" />

### Install via CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like Repeat in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.0.1+ is required to build Repeat.

#### Install via Podfile

To integrate Repeat into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
use_frameworks!
pod 'Repeast'
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



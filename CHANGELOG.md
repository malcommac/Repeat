## CHANGELOG

Latest version of Repeat is [0.5.4](https://github.com/malcommac/Repeat/releases/tag/0.5.4) published on 2018/04/28.

**Changelog - 0.5.4**:

- [#24](https://github.com/malcommac/Repeat/pull/24): Added `minutes` in `Interval` of `Repeater` timer.
 
**Changelog - 0.5.3**:

- [#23](https://github.com/malcommac/Repeat/pull/23): Allow passing queue as parameter for `.once` and `.every` inits; queue name is now generated automatically via `NSUUID`.

**Changelog - 0.5.2**:

- [#22](https://github.com/malcommac/Repeat/pull/22): Avoid over resume / suspend dispatch timer which causes crashes.

**Changelog - 0.5.1**:

- [#14](https://github.com/malcommac/Repeat/pull/14): Refactors equatable implementation to use an identity operator.

**Changelog - 0.5.0**:
* [#15](https://github.com/malcommac/Repeat/pull/15): Added `Debouncer` support.
* [#17](https://github.com/malcommac/Repeat/pull/17): Added `Throttler` support.

**Changelog - 0.3.2**:

* [#11](https://github.com/malcommac/Repeat/pull/11): Fixed an issue attempting to restart an `once` timer (thanks to [Thanh Pham](https://github.com/T-Pham)). Added `executing` state.

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

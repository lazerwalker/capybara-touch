capybara-touch
===============

A [capybara](https://github.com/jnicklas/capybara) driver that runs your tests against Mobile Webkit via the iOS Simulator. 

Installation and Xcode
-------------------------------------

Capybara-touch requires Xcode, the iOS SDK, and the Xcode Command Line Tools. As such, it is only officially supported on OS X. Xcode and the iOS SDK can be downloaded as a combined package for free from [Apple](https://developer.apple.com/xcode/). The Xcode Command Line tools can be downloaded from within the Downloads tab of the Xcode Preferences window, accessible from the Xcode menubar option, or directly from Apple's [Xcode Downloads Page](https://developer.apple.com/downloads/index.action?name=Xcode) (requires login).

Currently, capybara-touch also requires the iOS 6.1 simulator. You can still use Xcode 5 and the latest iOS 7 SDK, but the tests themselves must actually be run against the 6.1 simulator, which can be installed from the Downloads tab of the Xcode Preferences pane.

Warning
-------

This is alpha software. You will find that many pieces of Capybara functionality are not present, and are not yet documented as such. Please feel free to reach out via GitHub Issues if you run into any trouble.


Usage
-----

Add the capybara-touch gem to your Gemfile (use git for now; it will be added to Rubygems very soon, once the rate of development slows slightly):

```ruby
gem "capybara-touch", git: "git://github.com/lazerwalker/capybara-touch"
```

In your Capybara tests, set the driver to either `:iphone` or `:ipad`, depending on which device family you would like to target:

```ruby
Capybara.default_driver = :ipad
```

Goals
-----
Capybara-touch will be considered to be at version 1.0 when it is fully usable as a drop-in replacement in any Capybara test suite, in addition to having a select number of mobile-specific conveniences. This means:

* Full compatibility with the official Capybara test sute
* Support for any reasonable combination of device types and iOS versions (including iOS 7)
* Driver-specific Capybara commands for mobile-only functionality such as the accelerometer, location services, and gestures.

About
-----

The capybara-touch driver was written by Mike Walker. He can be reached at michael@lazerwalker.com.

A significant portion of the Ruby and JavaScript code was lovingly borrowed from the [capybara-webkit](https://github.com/thoughtbot/capybara-webkit) project.



License
-------

capybara-touch is Copyright (c) 2013 Mike Walker. It is free software, and may be redistributed under the terms specified in the LICENSE file.
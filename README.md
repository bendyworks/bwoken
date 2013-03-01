# Bwoken ![build status](https://secure.travis-ci.org/bendyworks/bwoken.png?branch=master)

Runs your UIAutomation tests from the command line for both iPhone and iPad, in the simulator or on your device.

Supports coffeescript and javascript.

![screenshot](https://raw.github.com/bendyworks/bwoken/master/doc/screenshot.png)


## Usage

### Running tests

Make sure bwoken is <a href="#installation">properly installed</a>. Then, build your project and run all your tests via:

<pre><code># will build and run all of your tests
$ rake

# will run one file, relative to integration/coffeescript (note: no file extension)
$ RUN=iphone/focused_test rake
</code></pre>

### Simulator or Device?

To run bwoken tests on your device, just plug it in! And if you want to run tests in the simulator, just unplug it!

As of bwoken 1.2.0, you can pass <code>SIMULATOR=true</code> as an environment variable to force simulator use even if your device is plugged in:

<pre><code># without a device connected, will run on the simulator:
$ rake

# with a device connected, will run on the device:
$ rake

# with a device connected, will run on the simulator:
$ SIMULATOR=true rake
</code></pre>

Your tests will look something like this:

<pre><code>$ rake
Building.............................................................................
.....................................................................................
.....................................................................................
.....................................................................................
.....................................................................................
.....................................................................................
.....................................................................................
................................................................................
Build Successful!

iphone  favorites.js
Start:  Favoriting a repository
Debug:  tap tableViews["Repositories"].cells["CITravis by Travis-ci"]
Debug:  tap navigationBar.rightButton
Debug:  tap actionSheet.elements["Add"]
Debug:  tap navigationBar.leftButton
Debug:  tap navigationBar.elements["Favorites"]
Debug:  navigationBar.elements["Favorites"].scrollToVisible
Debug:  tap navigationBar.elements["All"]
Pass:   Favoriting a repository
Start:  Unfavoriting a repository
Debug:  tap navigationBar.elements["Favorites"]
Debug:  tap tableViews["Repositories"].cells["CITravis by Travis-ci"]
Debug:  tap navigationBar.rightButton
Debug:  tap actionSheet.elements["Remove"]
Debug:  tap navigationBar.leftButton
Debug:  should be true null
Debug:  tap navigationBar.elements["All"]
Pass:   Unfavoriting a repository

Complete
 Duration: 23.419741s
</code></pre>


### Like Javascript?

Sometimes we'd like to have some javascript help us out. For example, what if you'd like <a href="http://underscorejs.org">Underscore.js</a> in your test suite? Simple! Just put it in <code>integration/javascript</code> and import it in your test:

<pre><code>#import "../underscore.js"
</code></pre>


## Installation

### Create an iOS project

If you don't have an iOS project already, go ahead and create it. If you already have a project, no worries: you can install bwoken at any point.

Ensure your project is in a workspace rather than simply a project:

* In Xcode, select File -&gt; Save as workspace...
* Save the workspace in the same directory as your .xcodeproj file

Note: This is done automatically if you use <a href="http://cocoapods.org/">CocoaPods</a>. I highly suggest you do!

### Prerequisites

Ensure Xcode is up-to-date.

Install rvm via <a href="https://rvm.io/rvm/install/">the instructions</a>. Ensure your after_cd_bundler rvm hook is enabled:

<pre><code>$ chmod u+x ~/.rvm/hooks/after_cd_bundler
</code></pre>

### Installation

In the terminal, inside the directory of your project (e.g., you should see a <code>ProjectName.xcodeproj</code> file), create an <code>.rvmrc</code> file and trigger its use:

<pre><code>$ echo 'rvm use 1.9.3@my_project' &gt; .rvmrc
$ rvm rvmrc trust .rvmrc
$ . .rvmrc
</code></pre>

Install bundler (a ruby library dependency manager) and init:

<pre><code>$ gem install bundler
$ bundle init
</code></pre>

This will create a <code>Gemfile</code>. Add bwoken to it and bundle:

<pre><code>$ echo "gem 'bwoken'" &gt;&gt; Gemfile
$ bundle
</code></pre>

Then, create a simple <code>Rakefile</code> and initialize your bwoken file structure:

<pre><code>$ echo "require 'bwoken/tasks'" &gt; Rakefile
$ rake bwoken:init
</code></pre>

Now, you can start <a href="#usage">using it!</a>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

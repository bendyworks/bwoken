# Bwoken

Runs your UIAutomation tests from the command line for both iPhone and iPad.

Supports coffeescript.

![screenshot](https://raw.github.com/bendyworks/bwoken/master/doc/screenshot.png)

## Installation

Add this line to your application's Gemfile:

    gem 'bwoken'

And then execute:

    $ bundle

Then, add the following line to your `Rakefile`:

    require 'bwoken/tasks'

## Usage

Run all your tests via:

    $ rake

## Living on the Edge

If you'd like the latest and greatest... that's not yet on rubygems, use this section as reference.

### Edge Installation

Add this line to your application's Gemfile:

    gem 'bwoken', :git => 'git://github.com/bendyworks/bwoken'

And then execute:

    $ bundle --binstubs

Then, add the following line to your `Rakefile`:

    require 'bwoken/tasks'

### Edge Usage

If you installed with the `--binstubs` option as specified as above, usage is the same:

    $ rake

If you didn't use the `--binstubs` option, you must prepend the command with `bundle exec`:

    $ bundle exec rake

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

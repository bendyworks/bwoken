require 'bwoken'
require 'rake/clean'

require 'slop'
require 'bwoken/cli/init'
require 'bwoken/cli/test'

BUILD_DIR          = 'build'
IPHONE_DIR         = 'integration/coffeescript/iphone'
VENDOR_JS_DIR      = 'integration/javascript'
RESULTS_DIR        = 'integration/tmp/results'

directory IPHONE_DIR
directory VENDOR_JS_DIR
directory RESULTS_DIR
directory BUILD_DIR

task :rake_deprecated do
  STDERR.puts 'WARNING: Invoking bwoken with rake is deprecated. Please use the `bwoken` executable now.'
  STDERR.puts 'Please see https://github.com/bendyworks/bwoken/wiki/Upgrading-from-v1-to-v2'
  STDERR.puts ''
end

namespace :bwoken do
  desc 'Create bwoken skeleton folders'
  task :init => :rake_deprecated do
    Bwoken::CLI::Init.new({}).run
  end
end

desc 'Compile coffeescript to javascript and copy vendor javascript'
task :coffeescript => :rake_deprecated do
  Bwoken::CLI::Test.new({}).transpile
end

desc 'remove any temporary products'
task :clean => :rake_deprecated do
  Bwoken::CLI::Test.new({}).clean
end

desc 'remove any generated file'
task :clobber => :rake_deprecated do
  Bwoken::CLI::Test.new({}).clobber
end


desc 'Compile the workspace'
task :compile => :rake_deprecated do
  opts = {:simulator => Bwoken::Device.should_use_simulator?}
  Bwoken::CLI::Test.new(opts).compile
end


device_families = %w(iphone ipad)

device_families.each do |device_family|

  namespace device_family do
    task :test => [:rake_deprecated, RESULTS_DIR, :coffeescript] do
      opts = {
        :simulator => Bwoken::Device.should_use_simulator?,
        :family => device_family
      }
      opts[:focus] = [ENV['RUN']] if ENV['RUN']

      Bwoken::CLI::Test.new(opts).test
    end
  end

  desc "Run tests for #{device_family}"
  task device_family => [:rake_deprecated, "#{device_family}:test"]

end

desc 'Run all tests without compiling first'
task :test => :rake_deprecated do
  opts = {
    :simulator => Bwoken::Device.should_use_simulator?
  }
  opts[:focus] = [ENV['RUN']] if ENV['RUN']
  opts[:family] = ENV['FAMILY'] if ENV['FAMILY']

  Bwoken::CLI::Test.new(opts).test
end

task :default => [:rake_deprecated, :compile, :test]

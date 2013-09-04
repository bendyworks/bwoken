require 'bwoken'
require 'rake/clean'

require 'slop'
require 'bwoken/cli/init'
require 'bwoken/cli/run'

COFFEESCRIPTS      = FileList['integration/coffeescript/**/*.coffee']
COMPILED_COFFEE    = COFFEESCRIPTS.pathmap('%{^integration/coffeescript,integration/tmp/javascript}d/%n.js')
JAVASCRIPTS        = FileList['integration/javascript/**/*.js']
COPIED_JAVASCRIPTS = JAVASCRIPTS.pathmap('%{^integration/javascript,integration/tmp/javascript}d/%f')

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
    Bwoken::CLI::Init.run(Slop.new({}) {})
  end
end

#COMPILED_COFFEE.zip(COFFEESCRIPTS).each do |target, source|
  #containing_dir = target.pathmap('%d')
  #directory containing_dir
  #file target => [containing_dir, source] do
    #Bwoken::Coffeescript.compile source, target
  #end
#end

#COPIED_JAVASCRIPTS.zip(JAVASCRIPTS).each do |target, source|
  #containing_dir = target.pathmap('%d')
  #directory containing_dir
  #file target => [containing_dir, source] do
    #sh "cp #{source} #{target}"
  #end
#end

desc 'Compile coffeescript to javascript and copy vendor javascript'
task :coffeescript => :rake_deprecated do
  Bwoken::CLI::Run.coffeescript # COMPILED_COFFEE + COPIED_JAVASCRIPTS
end

#CLEAN.include('integration/tmp/javascript')
#CLOBBER.include('integration/tmp')

desc 'remove any temporary products'
task :clean => :rake_deprecated do
  Bwoken::CLI::Run.clean
end

desc 'remove any generated file'
task :clobber => :rake_deprecated do
  Bwoken::CLI::Run.clobber
end


desc 'Compile the workspace'
task :compile => :rake_deprecated do
  exit_status = Bwoken::CLI::Run.compile
  #exit_status = Bwoken::Build.new.compile
  raise unless exit_status == 0
end


device_families = %w(iphone ipad)

device_families.each do |device_family|

  namespace device_family do
    task :test => [:rake_deprecated, RESULTS_DIR, :coffeescript] do
      if ENV['RUN']
        Bwoken::CLI::Run.focus [ENV['RUN']], device_family
      else
        Bwoken::CLI::Run.all device_family
      end
    end
  end

  desc "Run tests for #{device_family}"
  task device_family => [:rake_deprecated, "#{device_family}:test"]

end

desc 'Run all tests without compiling first'
task :test => :rake_deprecated do
  if ENV['FAMILY']
    Rake::Task[ENV['FAMILY']].invoke
  else
    device_families.each do |device_family|
      Rake::Task[device_family].invoke
    end
  end
end

task :default => [:rake_deprecated, :compile, :test]

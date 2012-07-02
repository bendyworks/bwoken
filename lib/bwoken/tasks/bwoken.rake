require 'bwoken'
require 'rake/clean'

namespace :bwoken do
  desc 'Create bwoken skeleton folders'
  task :init do
    paths = []
    paths << Bwoken.results_path
    paths << Bwoken.test_suite_path
    paths << "#{Bwoken::Coffeescript.source_folder}/iphone"
    paths << "#{Bwoken::Coffeescript.source_folder}/ipad"
    paths << "#{Bwoken.path}/javascript"

    paths.each do |path|
      puts "Creating #{path}"
      FileUtils.mkdir_p path
    end

    example = "#{Bwoken::Coffeescript.source_folder}/iphone/example.coffee"
    unless File.file?(example)
      example_dependancy = File.join(Bwoken.path, 'javascript', 'example_js.js')
      puts "Creating #{example}"
      puts "Creating #{example_dependancy}"
      open(example_dependancy, 'w') do |io|
        io.puts 'Place your javascript here'
      end
      open(example, 'w') do |io|
        io.puts '#import ../example_js.js'
        io.puts 'target = UIATarget.localTarget()'
        io.puts 'window = target.frontMostApp().mainWindow()'
      end
    end

  end
end

# task :clean_db do
  # puts "Cleaning the application's sqlite cache database"
  # system 'rm -rf ls -1d ~/Library/Application\ Support/iPhone\ Simulator/**/Applications/**/Library/Caches/TravisCI*.sqlite'
# end

desc 'Compile the workspace'
task :build do
  exit_status = Bwoken::Build.new.compile
  raise unless exit_status == 0
end



COFFEESCRIPTS = FileList['integration/coffeescript/**/*.coffee']
COMPILED_COFFEE = COFFEESCRIPTS.pathmap('%{^integration/coffeescript,integration/tmp/javascript}d/%n.js')
JAVASCRIPTS = FileList['integration/javascript/**/*.js']
COPIED_JAVASCRIPTS = JAVASCRIPTS.pathmap('%{^integration/javascript,integration/tmp/javascript}d/%f')

COMPILED_COFFEE.zip(COFFEESCRIPTS).each do |target, source|
  containing_dir = target.pathmap('%d')
  directory containing_dir
  file target => [containing_dir, source] do
    Bwoken::Coffeescript.compile source, target
  end
end

COPIED_JAVASCRIPTS.zip(JAVASCRIPTS).each do |target, source|
  containing_dir = target.pathmap('%d')
  directory containing_dir
  file target => [containing_dir, source] do
    sh "cp #{source} #{target}"
  end
end

task :coffeescript => (COMPILED_COFFEE + COPIED_JAVASCRIPTS)

CLEAN.include('integration/tmp/javascript')
CLOBBER.include('integration/tmp')




device_families = %w(iphone ipad)

device_families.each do |device_family|

  namespace device_family do
    task :test => :coffeescript do
      if ENV['RUN']
        Bwoken::Script.run_one ENV['RUN'], device_family
      else
        Bwoken::Script.run_all device_family
      end
    end
  end

  desc "Run tests for #{device_family}"
  task device_family => "#{device_family}:test"

end

desc 'Run all tests without compiling first'
task :test do
  if ENV['FAMILY']
    Rake::Task[ENV['FAMILY']].invoke
  else
    device_families.each do |device_family|
      Rake::Task[device_family].invoke
    end
  end
end

task :default => [:build, :test]

require 'bwoken'

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

desc 'Remove result and trace files'
task :clean do
  print "Removing #{Bwoken.tmp_path}/* ... "
  system "rm -rf #{Bwoken.tmp_path}/*"
  puts 'done.'
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

task :coffeescript do
  Bwoken::Coffeescript.clean
  if File.exists?(File.join(Bwoken.path, 'javascript'))
    system("cp -r #{File.join(Bwoken.path,'javascript')} #{Bwoken.tmp_path}")
  end
  Bwoken::Coffeescript.compile_all
end

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

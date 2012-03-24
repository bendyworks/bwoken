require 'bwoken'

desc 'Remove result and trace files'
task :clean do
  print 'Removing instrumentscli*.trace & automation/results/* ... '
  system 'rm -rf instrumentscli*.trace automation/results/*'
  puts 'done.'
end

# task :clean_db do
  # puts "Cleaning the application's sqlite cache database"
  # system 'rm -rf ls -1d ~/Library/Application\ Support/iPhone\ Simulator/**/Applications/**/Library/Caches/TravisCI*.sqlite'
# end

desc 'Compile the workspace'
task :build do
  Bwoken::Build.new.compile
end

task :coffeescript do
  Bwoken::Coffeescript.compile_all
end

device_families = %w(iphone ipad)

device_families.each do |device_family|

  namespace device_family do
    task :test => :coffeescript do
      script = Bwoken::Script.new
      script.path = "automation/#{device_family}.js"
      script.device_family = device_family
      script.run
    end
  end

  desc "Run tests for #{device_family}"
  task device_family => "#{device_family}:test"

end

desc 'Build and run tests'
task :test => ([:build] + device_families)

task :default => :test

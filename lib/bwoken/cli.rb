require 'slop'

%w(version cli/init cli/run).each do |f|
  require File.expand_path("../#{f}", __FILE__)
end

ran_command = nil

init_banner, run_banner = <<-INIT_BANNER, <<-RUN_BANNER
Initialize your UIAutomation project.


== Options ==
INIT_BANNER
Run your tests. If you don't specify which tests, bwoken will run them all

    bwoken run --simulator # runs all tests in the simulator

You can specify a device type if you only want to run, say, iPad tests:

    bwoken run --device ipad

If you only want to run a specific test, you can focus on it:

    bwoken run --focus login # runs iPhone and iPad tests named "login"


== Options ==
RUN_BANNER

opts = Slop.parse :help => true do
  on :v, :version, 'Print the version' do
    puts Bwoken::VERSION
    exit 0
  end

  command 'init' do
    banner init_banner

    run { ran_command = 'init' }
  end

  command 'run' do
    banner run_banner

    on :simulator, 'Use simulator, even when an iDevice is connected'

    on :device=, 'Run only one device type, either ipad or iphone. Default is to run on both',
      :match => /\A(?:ipad|iphone)\Z/i
    on :scheme=, 'Specify a custom scheme'
    on :flags=, 'Specify custom build flags (e.g., --flags="-arch=i386,foo=bar")', :as => Array, :default => []
    on :formatter=, 'Specify a custom formatter (e.g., --formatter=passthru)', :default => 'colorful'
    on :focus=, 'Specify particular tests to run', :as => Array, :default => []

    run { ran_command = 'run' }
  end

end

case ran_command
when 'init' then Bwoken::CLI::Init.run(opts.commands['init'])
when 'run' then Bwoken::CLI::Run.run(opts.commands['run'])
else puts opts
end

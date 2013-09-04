require 'slop'

%w(version cli/init cli/run).each do |f|
  require File.expand_path("../#{f}", __FILE__)
end

ran_command = nil

opts = Slop.parse :help => true do
  on :v, :version, 'Print the version' do
    puts Bwoken::VERSION
    exit 0
  end

  command 'init' do
    banner Bwoken::CLI::Init.help_banner

    run { ran_command = 'init' }
  end

  command 'run' do
    banner Bwoken::CLI::Run.help_banner

    on :simulator, 'Use simulator, even when an iDevice is connected'

    on :device=, 'Run only one device type, either ipad or iphone. Default is to run on both',
      :match => /\A(?:ipad|iphone)\Z/i
    on :scheme=, 'Specify a custom scheme'
    on :flags=, 'Specify custom build flags (e.g., --flags="-arch=i386,foo=bar")', :as => Array, :default => []
    on :formatter=, 'Specify a custom formatter (e.g., --formatter=passthru)', :default => 'colorful'
    on :focus=, 'Specify particular tests to run', :as => Array, :default => []
    on :clean, 'Remove any temporary products'
    on :clobber, 'Remove any generated file'

    run { ran_command = 'run' }
  end

end

if File.exists?('Rakefile')
  contents = open('Rakefile').read.strip
  if contents =~ /\Arequire ["']bwoken\/tasks["']\Z/
    STDERR.puts 'You may safely delete Rakefile'
  elsif contents =~ /require ["']bwoken\/tasks["']/
    STDERR.puts %Q|You may safely remove the "require 'bwoken/tasks'" line from Rakefile|
  end
end

case ran_command
when 'init' then Bwoken::CLI::Init.run(opts.commands['init'])
when 'run' then Bwoken::CLI::Run.run(opts.commands['run'])
else puts opts
end

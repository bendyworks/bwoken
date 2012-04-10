require 'colorful'

require 'bwoken/formatter'

module Bwoken
  class ColorfulFormatter < Formatter

    on :complete do |line|
      tokens = line.split(' ')
      puts %Q( \n#{"Complete".send(@failed ? :red : :green)}\n Duration: #{tokens[5].sub(';','').underline.bold}\n )
    end

    on :debug do |line|
      filtered_line = line.sub(/(target\.frontMostApp.+)\.tap\(\)/, "#{'tap'.yellow} \\1")
      filtered_line = filtered_line.gsub(/\[("[^\]]*")\]/, "[" + '\1'.magenta + "]")
      filtered_line = filtered_line.sub('target.frontMostApp().mainWindow().','')
      tokens = filtered_line.split(' ')
      puts "#{tokens[3].cyan}\t#{tokens[4..-1].join(' ')}"
    end

    on :error do |line|
      @failed = true
      tokens = line.split(' ')
      puts "#{tokens[3].bold.red}\t#{tokens[4..-1].join(' ').underline.bold}"
    end

    on :fail do |line|
      @failed = true
      tokens = line.split(' ')
      puts "#{tokens[3].bold.red}\t#{tokens[4..-1].join(' ').underline.bold}"
    end

    on :start do |line|
      tokens = line.split(' ')
      puts "#{tokens[3].cyan}\t#{tokens[4..-1].join(' ')}"
    end

    on :pass do |line|
      tokens = line.split(' ')
      puts "#{tokens[3].green}\t#{tokens[4..-1].join(' ')}"
    end

    on :before_script_run do |path|
      @failed = false
      tokens = path.split('/')
      puts
      puts "#{tokens[-2]}\t#{tokens[-1]}".cyan
    end

    on :before_build_start do
      print "Building".blue
    end

    on :build_line do |line|
      print '.'.blue
    end

    on :build_successful do |line|
      puts
      puts 'Build Successful!'.green
    end

    on :build_failed do |build_log, error_log|
      puts build_log
      puts 'Standard Error:'.yellow
      puts error_log
      puts 'Build failed!'.red
    end
  end
end

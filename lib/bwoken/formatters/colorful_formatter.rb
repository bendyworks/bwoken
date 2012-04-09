require 'colorful'

require 'bwoken/formatter'

module Bwoken
  class ColorfulFormatter < Formatter

    on :complete do |line|
      tokens = line.split(' ')
      puts "\n#{tokens[0..2].join(' ').cyan}\n Duration: #{tokens[5].sub(';','').underline.bold}\n\n"
    end

    on :debug do |line|
      tokens = line.split(' ')
      # puts "#{tokens[3].cyan}\t#{tokens[4..-1].join(' ')}"
    end

    on :fail do |line|
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

    on :build_line do |line|
      print '.'.blue
    end

    on :build_successful do |line|
      puts
      puts
      puts '### Build Successful ###'.green
      puts
    end

    on :build_failed do |build_log, error_log|
      puts build_log
      puts 'Standard Error:'.yellow
      puts error_log
      puts '## Build failed ##'.red
    end
  end
end

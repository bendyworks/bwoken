require 'colorful'

require 'bwoken/formatter'

module Bwoken
  class ColorfulFormatter < Formatter

    on :debug do |line|
      tokens = line.split(' ')
      puts "#{tokens[1]} #{tokens[3].yellow}\t#{tokens[4..-1].join(' ')}"
    end

    on :fail do |line|
      tokens = line.split(' ')
      puts "#{tokens[1]} #{tokens[3].red}\t#{tokens[4..-1].join(' ')}"
    end

    on :pass do |line|
      tokens = line.split(' ')
      puts "#{tokens[1]} #{tokens[3].green}\t#{tokens[4..-1].join(' ')}"
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

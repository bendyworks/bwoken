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

    on :other do |line|
      puts line
    end

  end
end

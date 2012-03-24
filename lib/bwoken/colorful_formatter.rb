require 'colorful'

require 'bwoken/formatter'

module Bwoken
  class ColorfulFormatter < Formatter

    on :debug do |line|
      tokens = line.split(' ')
      tokens.delete_at(2)
      tokens.delete_at(0)
      puts "#{tokens[0]} #{tokens[1].yellow}\t#{tokens[2..-1].join(' ')}"
    end

    on :fail do |line|
      tokens = line.split(' ')
      tokens.delete_at(2)
      tokens.delete_at(0)
      puts "#{tokens[0]} #{tokens[1].red}\t#{tokens[2..-1].join(' ')}"
    end

    on :pass do |line|
      tokens = line.split(' ')
      tokens.delete_at(2)
      tokens.delete_at(0)
      puts "#{tokens[0]} #{tokens[1].green}\t#{tokens[2..-1].join(' ')}"
    end

    on :other do |line|
      puts line
    end

  end
end

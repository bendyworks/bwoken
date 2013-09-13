require 'bwoken/formatter'

module Bwoken
  class PassthruFormatter < Formatter
    [:before_build_start, :build_line, :build_successful, :build_failed,
     :complete, :debug, :error, :fail, :other, :pass, :start].each do |cb|
      on cb do |line|
        puts line
      end
    end
  end
end

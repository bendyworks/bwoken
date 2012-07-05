require 'fileutils'
require 'coffee_script/source'
require 'json'
require 'execjs'

module Bwoken
  class Coffeescript
    class << self

      def coffee_script_source
        return @coffeescript if @coffeescript

        @coffeescript = ''
        open(CoffeeScript::Source.bundled_path) do |f|
          @coffeescript << f.read
        end
        @coffeescript
      end

      def context
        @context ||= ExecJS.compile(coffee_script_source)
      end

      def precompile coffeescript
        coffeescript.lines.partition {|line| line =~ /^#import .*$/}.map(&:join)
      end

      def compile source, target
        import_strings, sans_imports = precompile(IO.read source)

        javascript = self.context.call 'CoffeeScript.compile', sans_imports, :bare => true

        write import_strings, javascript, :to => target
      end

      def write *args
        to_hash = args.last
        chunks = args[0..-2]

        File.open(to_hash[:to], 'w') do |io|
          chunks.each do |chunk|
            io.puts chunk unless chunk.nil? || chunk == ''
          end
        end
      end

    end
  end
end

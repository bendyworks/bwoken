require 'fileutils'
require 'coffee_script/source'
require 'json' if RUBY_VERSION =~ /^1\.8\./
require 'execjs'

module Bwoken
  class Coffeescript
    class << self

      def coffee_script_source
        IO.read(CoffeeScript::Source.bundled_path)
      end

      def context
        @context ||= ExecJS.compile(coffee_script_source)
      end

      def compile source, target
        coffeescript = IO.read(source)

        import_strings = coffeescript.scan(/#import .*$/) || []
        precompiled = coffeescript.gsub(/#import .*$/,'')

        javascript = self.context.call('CoffeeScript.compile', precompiled, :bare => true)

        File.open(target, 'w') do |io|
          import_strings.each do |import_string|
            io.puts import_string
          end
          io.puts javascript
        end
      end

    end

  end
end

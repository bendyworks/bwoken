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

      def precompile coffeescript
        import_strings = coffeescript.scan(/#import .*$/) || []
        sans_imports = coffeescript.gsub(/#import .*$/,'')

        [import_strings, sans_imports]
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
          chunks.flatten.each do |chunk|
            io.puts chunk
          end
        end
      end

    end
  end
end

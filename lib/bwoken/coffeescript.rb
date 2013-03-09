require 'fileutils'
require 'coffee_script/source'
require 'json'
require 'execjs'

require File.expand_path('../coffeescript/import_string', __FILE__)
require File.expand_path('../coffeescript/github_import_string', __FILE__)

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
        coffeescript.lines.partition {|line| line =~ /^#(?:github|import) .*$/}
      end

      def compile source, target
        githubs_and_imports, sans_imports = precompile(IO.read source)

        javascript = coffeescript_to_javascript sans_imports.join
        import_strings = githubs_to_imports(githubs_and_imports)

        write import_strings, javascript, :to => target
      end

      def coffeescript_to_javascript coffee
        self.context.call 'CoffeeScript.compile', coffee, :bare => true
      end

      def githubs_to_imports strings
        strings.map do |string|
          obj = import_string_object(string)
          obj.parse
          obj.to_s
        end.join("\n")
      end

      def import_string_object string
        if string =~ /^#github/
          GithubImportString.new(string)
        else
          ImportString.new(string)
        end
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

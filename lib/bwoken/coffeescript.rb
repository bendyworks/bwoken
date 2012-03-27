require 'coffee_script/source'
require 'execjs'

module Bwoken
  class Coffeescript
    class << self

      def source_folder
        'automation/coffeescript'
      end

      def destination_folder
        Bwoken.test_suite_path
      end

      def test_files
        "#{source_folder}/*.coffee"
      end

      def coffee_script_source
        IO.read(CoffeeScript::Source.bundled_path)
      end

      def context
        @context ||= ExecJS.compile(coffee_script_source)
      end

      def compile_all
        Dir[test_files].each do |filename|
          new(filename).make
        end
      end

    end

    def initialize filename
      @source_file = filename
    end

    def destination_file
      basename = File.basename(@source_file, '.coffee')
      "#{self.class.destination_folder}/#{basename}.js"
    end

    def make
      raw_javascript = compile
      javascript = translate_to_uiautomation raw_javascript
      save javascript
    end

    def source_contents
      IO.read(@source_file)
    end

    def compile
      source = source_contents
      self.class.context.call('CoffeeScript.compile', source, :bare => true)
    end

    def translate_to_uiautomation raw_javascript
      raw_javascript
    end

    def save javascript
      File.open(destination_file, 'w') do |io|
        io.puts javascript
      end
    end

  end
end

require 'fileutils'
require 'coffee_script/source'
require 'execjs'

module Bwoken
  class Coffeescript
    class << self

      def source_folder
        File.join(Bwoken.project_path, 'automation/coffeescript')
      end

      def test_files
        "#{source_folder}/**/*.coffee"
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

      def clean
        FileUtils.rm_rf compiled_javascript_path
      end

      def compiled_javascript_path
        File.join(Bwoken.project_path, 'automation/tmp/javascript')
      end

    end

    def initialize path
      @source_file = path
    end

    def destination_folder
      subpath = File.dirname(@source_file.sub(Regexp.new(self.class.source_folder + '/'), '')).sub('.','')
      File.join(self.class.compiled_javascript_path, subpath)
    end

    def destination_file
      basename = File.basename(@source_file, '.coffee')
      "#{self.destination_folder}/#{basename}.js"
    end

    def make
      FileUtils.mkdir_p(destination_folder)
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

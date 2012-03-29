require 'fileutils'
require 'coffee_script/source'
require 'json' if RUBY_VERSION =~ /^1\.8\./
require 'execjs'

module Bwoken
  class Coffeescript
    class << self

      def source_folder
        File.join(Bwoken.path, 'coffeescript')
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
        File.join(Bwoken.path, 'tmp', 'javascript')
      end

    end

    attr_accessor :import_strings

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
      javascript = compile
      save javascript
    end

    def source_contents
      IO.read(@source_file)
    end

    def compile
      source = precompile(source_contents)
      self.class.context.call('CoffeeScript.compile', source, :bare => true)
    end

    def precompile coffeescript
      capture_imports coffeescript
      remove_imports coffeescript
    end

    def capture_imports raw_coffeescript
      self.import_strings = raw_coffeescript.scan(/#import .*$/)
    end

    def remove_imports raw_coffeescript
      raw_coffeescript.gsub(/#import .*$/,'')
    end

    def save javascript
      File.open(destination_file, 'w') do |io|
        import_strings.each do |import_string|
          io.puts import_string
        end unless import_strings.nil?
        io.puts javascript
      end
    end

  end
end

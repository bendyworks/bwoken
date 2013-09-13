require 'bwoken'
require 'bwoken/script'

module Bwoken
  class DeviceRunner
    attr_accessor :focus
    attr_accessor :formatter
    attr_accessor :app_dir

    alias_method :feature_names, :focus

    def initialize
      yield self if block_given?
    end

    def execute
      scripts.each(&:run)
    end

    def device_family
      Device.device_type
    end

    def scripts
      script_filenames.map do |filename|
        Script.new do |s|
          s.path = filename
          s.device_family = device_family
          s.formatter = formatter
          s.app_dir = app_dir
        end
      end
    end

    def script_filenames
      if focus.respond_to?(:length) && focus.length > 0
        test_files_from_feature_names
      else
        all_test_files
      end
    end

    def test_files_from_feature_names
      feature_names.map do |feature_name|
        File.join(Bwoken.test_suite_path, device_family, "#{feature_name}.js")
      end
    end

    def all_test_files
      all_files_in_test_dir - helper_files
    end

    def all_files_in_test_dir
      Dir["#{Bwoken.test_suite_path}/#{device_family}/**/*.js"]
    end

    def helper_files
      Dir["#{Bwoken.test_suite_path}/#{device_family}/**/helpers/**/*.js"]
    end

  end
end

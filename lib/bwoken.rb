require 'fileutils'

require 'bwoken/version'
require 'bwoken/simulator'
require 'bwoken/build'
require 'bwoken/script'
require 'bwoken/coffeescript'

module Bwoken
  class << self
    def app_name
      File.basename(project_path)
    end

    def app_dir
      File.join(build_path, "#{app_name}.app")
    end

    def project_path
      Dir.pwd
    end

    def test_suite_path
      Bwoken::Coffeescript.compiled_javascript_path
    end

    def path_to_automation_template
      '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Instruments/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate'
    end

    def build_path
      File.join(project_path, 'build').tap do |dir_name|
        FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
      end
    end

    def path
      File.join(project_path, 'integration')
    end

    def workspace
      File.join(project_path, "#{app_name}.xcworkspace")
    end

    def results_path
      File.join(path, 'results').tap do |dir_name|
        FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
      end
    end

  end
end

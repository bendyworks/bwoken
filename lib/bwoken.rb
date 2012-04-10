require 'fileutils'

require 'bwoken/build'
require 'bwoken/coffeescript'
require 'bwoken/formatters/colorful_formatter'
require 'bwoken/script'
require 'bwoken/simulator'
require 'bwoken/version'

module Bwoken
  class << self
    def path
      File.join(project_path, 'integration')
    end

    def tmp_path
      File.join(path, 'tmp')
    end

    def app_name
      File.basename(project_path)
    end

    def app_dir
      File.join(build_path, "#{app_name}.app")
    end

    def formatter
      @formatter ||= Bwoken::ColorfulFormatter.new
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

    def workspace
      workspace = File.join(project_path, "#{app_name}.xcworkspace")
      File.exists?(workspace) ? workspace : File.join(project_path, "#{app_name}.xcodeproj")
    end

    def results_path
      File.join(tmp_path, 'results').tap do |dir_name|
        FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
      end
    end

  end
end

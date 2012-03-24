require 'bwoken/version'
require 'bwoken/simulator'
require 'bwoken/build'
require 'bwoken/script'
require 'bwoken/coffeescript'

require 'fileutils'
require 'open3'
require 'colorful'

module Bwoken
  class << self
    def app_name
      File.basename(project_directory)
    end

    def project_directory
      Dir.pwd
    end

    def path_to_automation
      '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Instruments/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate'
    end

    def build_directory
      Dir.mkdir('build') unless Dir.exists?('build')
      File.join(project_directory, 'build')
    end

    def app
      File.join(build_directory, "#{app_name}.app")
    end

    def workspace
      File.join(project_directory, "#{app_name}.xcworkspace")
    end

    def results_path
      File.join(project_directory, 'automation', 'results').tap do |dir_name|
        FileUtils.mkdir_p(dir_name) unless Dir.exists?(dir_name)
      end
    end

  end
end

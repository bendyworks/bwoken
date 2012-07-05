require 'fileutils'

require 'bwoken/build'
require 'bwoken/coffeescript'
require 'bwoken/formatters/colorful_formatter'
require 'bwoken/script'
require 'bwoken/simulator'
require 'bwoken/device'
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
      File.basename(File.basename(workspace_or_project, '.xcodeproj'), '.xcworkspace')
    end

    def formatter
      @formatter ||= Bwoken::ColorfulFormatter.new
    end

    def project_path
      Dir.pwd
    end

    def test_suite_path
      File.join(tmp_path, 'javascript')
    end

    def path_to_automation_template
      '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Instruments/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate'
    end

    %w(xcworkspace xcodeproj).each do |xcode_root|
      define_method xcode_root do
        paths = Dir["#{project_path}/*.#{xcode_root}"]
        fail "Error: Found more than one #{xcode_root} file in root" if paths.count > 1
        paths.first
      end
    end

    def workspace_or_project
      ws = xcworkspace
      File.exists?(ws) ? ws : xcodeproj
    end

    def workspace_or_project_flag
      ws = xcworkspace
      if File.exists?(ws)
        "-workspace #{ws}"
      else
        "-project #{xcodeproj}"
      end
    end

    def results_path
      File.join(tmp_path, 'results').tap do |dir_name|
        FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
      end
    end

  end
end

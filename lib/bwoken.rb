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

    def path_to_developer_dir
      `xcode-select -print-path`.strip
    end

    def path_to_automation_template
      template = nil
      `xcrun instruments -s 2>&1 | grep Automation.tracetemplate`.split("\n").each do |path|
        path = path.gsub(/^\s*"|",\s*$/, "")
        template = path if File.exists?(path)
        break if template
      end
      template
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
      ws && File.exists?(ws) ? ws : xcodeproj
    end

    def workspace_or_project_flag
      ws = xcworkspace
      if ws && File.exists?(ws)
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

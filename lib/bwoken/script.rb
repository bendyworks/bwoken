require 'fileutils'
require 'open3'

require 'bwoken/formatters/colorful_formatter'

module Bwoken

  class ScriptFailedError < RuntimeError; end

  class Script

    attr_accessor :path

    class << self

      def run_all device_family
        Simulator.device_family = device_family

        puts "#{Bwoken.test_suite_path}/#{device_family}/**/*.js"
        Dir["#{Bwoken.test_suite_path}/#{device_family}/**/*.js"].each do |javascript|
          run(javascript)
        end
      end

      def run javascript_path
        script = new
        script.path = javascript_path
        script.run
      end

      def trace_file_path
        File.join(Bwoken.path, 'tmp', 'trace')
      end

    end

    def env_variables
      {
        'UIASCRIPT' => path,
        'UIARESULTSPATH' => Bwoken.results_path
      }
    end

    def env_variables_for_cli
      env_variables.map{|key,val| "-e #{key} #{val}"}.join(' ')
    end

    def cmd
      "#{File.expand_path('../../../bin', __FILE__)}/unix_instruments.sh \
        -D #{self.class.trace_file_path} \
        -t #{Bwoken.path_to_automation_template} \
        #{Bwoken.app_dir} \
        #{env_variables_for_cli}"
    end

    def formatter
      Bwoken::ColorfulFormatter
    end

    def make_results_path_dir
      FileUtils.mkdir_p Bwoken.results_path
    end

    def run
      make_results_path_dir

      exit_status = 0
      Open3.popen2e(cmd) do |stdin, stdout, wait_thr|
        exit_status = formatter.format stdout
      end
      raise ScriptFailedError.new('Test Script Failed') unless exit_status == 0
    end

  end
end

require 'fileutils'
require 'open3'

require 'bwoken/formatters/colorful_formatter'

module Bwoken
  class Script

    attr_accessor :device_family, :path

    def self.run
      script = new
      yield script
      script.run
    end

    def device_family
      @device_family ||= ENV['FAMILY'] || 'iphone'
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
      "unix_instruments.sh \
        -t #{Bwoken.path_to_automation} \
        #{Bwoken.app_dir} \
        #{env_variables_for_cli}"
    end

    def simulator
      Bwoken::Simulator
    end

    def set_simulator_device_family!
      simulator.device_family = device_family
    end

    def formatter
      Bwoken::ColorfulFormatter
    end

    def make_results_path_dir
      FileUtils.mkdir_p Bwoken.results_path
    end

    def run
      set_simulator_device_family!
      make_results_path_dir

      exit_status = 0
      Open3.popen2e(cmd) do |stdin, stdout, wait_thr|
        exit_status = formatter.format stdout
      end
      raise 'Build failed' unless exit_status == 0
    end

  end
end

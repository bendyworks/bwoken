require 'fileutils'
require 'open3'

require 'bwoken/colorful_formatter'

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

    def cmd
      variables = env_variables.map{|key,val| "-e #{key} #{val}"}.join(' ')

      "unix_instruments.sh \
        -t #{Bwoken.path_to_automation} \
        #{Bwoken.app} \
        #{variables}"
    end

    def run
      Bwoken::Simulator.device_family = device_family

      FileUtils.mkdir_p Bwoken.results_path
      exit_status = 0
      Open3.popen2e(cmd) do |stdin, stdout, wait_thr|
        exit_status = Bwoken::ColorfulFormatter.format stdout
      end
      raise 'Build failed' unless exit_status == 0
    end

  end
end

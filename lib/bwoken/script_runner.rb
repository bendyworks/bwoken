require 'bwoken/simulator_runner'
require 'bwoken/device_runner'

module Bwoken
  class ScriptRunner
    attr_accessor :family
    attr_accessor :focus
    attr_accessor :formatter
    attr_accessor :simulator
    attr_accessor :device
    attr_accessor :app_dir

    alias_method :feature_names, :focus

    def initialize
      yield self if block_given?
    end

    def execute
      if simulator
        execute_in_simulator
      else
        execute_on_device
      end
    end

    def execute_in_simulator
      chosen_families.each do |device_family|
        execute_for_family device_family
      end
    end

    def execute_for_family device_family
      runner_for_family(device_family).execute
    end

    def runner_for_family device_family
      SimulatorRunner.new do |sr|
        sr.device_family = device_family
        sr.focus = focus
        sr.formatter = formatter
        sr.simulator = simulator
        sr.device = device
        sr.app_dir = app_dir
      end
    end

    def chosen_families
      if family == 'all' || family == [] || family.nil?
        %w(iphone ipad)
      else
        Array(family)
      end
    end

    def execute_on_device
      runner_for_device.execute
    end

    def runner_for_device
      DeviceRunner.new do |dr|
        dr.focus = focus
        dr.formatter = formatter
        dr.app_dir = app_dir
        dr.device = device
      end
    end

  end
end

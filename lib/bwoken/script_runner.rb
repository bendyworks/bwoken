require 'bwoken/device_runner'

module Bwoken
  class ScriptRunner
    attr_accessor :family
    attr_accessor :focus
    attr_accessor :formatter
    attr_accessor :simulator
    attr_accessor :app_dir

    alias_method :feature_names, :focus

    def initialize
      yield self if block_given?
    end

    def execute
      chosen_families.each do |device_family|
        execute_for_family device_family
      end
    end

    def execute_for_family device_family
      runner_for_family(device_family).execute
    end

    def runner_for_family device_family
      DeviceRunner.new do |dr|
        dr.family = device_family
        dr.focus = focus
        dr.formatter = formatter
        dr.simulator = simulator
        dr.app_dir = app_dir
      end
    end

    def chosen_families
      if family == 'all' || family == [] || family.nil?
        %w(iphone ipad)
      else
        Array(family)
      end
    end

  end
end

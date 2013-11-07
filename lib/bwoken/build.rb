require 'open3'
require 'bwoken'
require 'bwoken/device'

module Bwoken
  class BuildFailedError < RuntimeError; end

  class Build

    class << self
      def build_path
        File.join(Bwoken.project_path, 'build')
      end

      def xcconfig
        File.join(File.dirname(__FILE__), 'configs', 'bwoken.xcconfig')
      end

      def sdk simulator
        simulator ? 'iphonesimulator' : 'iphoneos'
      end

      def configuration_build_dir simulator
        File.join(build_path, sdk(simulator))
      end

      def app_dir simulator
        File.join(configuration_build_dir(simulator), "#{Bwoken.app_name}.app")
      end
    end

    #attr_accessor :flags #TODO: implement
    attr_accessor :formatter
    attr_accessor :scheme
    attr_accessor :simulator
    attr_accessor :configuration
    attr_accessor :sdk_version
    attr_accessor :verbose

    def initialize
      #self.flags = [] #TODO: implement
      self.scheme = Bwoken.app_name
      self.configuration = 'Debug'

      yield self if block_given?
    end

    def sdk
      self.class.sdk(simulator)
    end

    def env_variables
      {
        'BWOKEN_CONFIGURATION_BUILD_DIR' => self.class.configuration_build_dir(simulator)
      }
    end

    def variables_for_cli
      env_variables.map{|key,val| "#{key}=#{val}"}.join(' ')
    end

    def scheme_string
      Bwoken.xcworkspace ? "-scheme #{scheme}" : ''
    end

    def cmd
      "xcodebuild \
        #{Bwoken.workspace_or_project_flag} \
        #{scheme_string} \
        -configuration #{configuration} \
        -sdk #{sdk}#{sdk_version} \
        -xcconfig #{self.class.xcconfig} \
        #{variables_for_cli} \
        clean build"
    end

    def compile
      formatter.before_build_start

      succeeded, out_string, err_string = RUBY_VERSION == '1.8.7' ? compile_18 : compile_19_plus

      if succeeded
        formatter.build_successful out_string
      else
        formatter.build_failed out_string, err_string
        fail BuildFailedError.new
      end
    end

    def compile_18
      out_string, err_string = '', ''
      a, b, c = Open3.popen3(cmd) do |stdin, stdout, stderr|
        out_string = formatter.format_build stdout
        err_string = stderr.read
      end

      [a.to_s !~ /BUILD FAILED/, out_string, err_string]
    end

    def compile_19_plus
      ret = nil
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|

        out_string = formatter.format_build stdout
        err_string = stderr.read
        exit_status = wait_thr.value if wait_thr

        ret = [exit_status == 0, out_string, err_string]
      end
      ret
    end
  end
end

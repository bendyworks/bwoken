require 'open3'
require 'bwoken/device'

module Bwoken
  class Build

    def app_dir
      File.join(configuration_build_dir, "#{Bwoken.app_name}.app")
    end

    def build_path
      File.join(Bwoken.project_path, 'build')
    end

    def scheme
      Bwoken.app_name
    end

    def configuration
      'Debug'
    end

    def sdk
      if Bwoken::Device.connected?
        'iphoneos'
      else
        'iphonesimulator5.1'
      end
    end

    def configuration_build_dir
      File.join(build_path, sdk)
    end

    def env_variables
      {
        'GCC_PREPROCESSOR_DEFINITIONS' => 'TEST_MODE=1',
        'CONFIGURATION_BUILD_DIR' => configuration_build_dir
      }
    end

    def variables_for_cli
      env_variables.map{|key,val| "#{key}=#{val}"}.join(' ')
    end

    def cmd
      "xcodebuild \
        #{Bwoken.workspace_or_project_flag} \
        #{"-scheme #{scheme}" if Bwoken.xcworkspace} \
        -configuration #{configuration} \
        -sdk #{sdk} \
        #{variables_for_cli} \
        clean build"
    end

    def compile
      Bwoken.formatter.before_build_start

      exit_status = 0
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|

        out_string = Bwoken.formatter.format_build stdout

        exit_status = wait_thr.value if wait_thr

        if exit_status == 0 # Build Successful
          Bwoken.formatter.build_successful out_string
        else # Build Failed
          Bwoken.formatter.build_failed out_string, stderr.read
          return exit_status
        end
      end
      exit_status
    end
  end
end

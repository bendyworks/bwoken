require 'open3'

module Bwoken
  class Build

    def scheme
      Bwoken.app_name
    end

    def configuration
      'Debug'
    end

    def sdk
      'iphonesimulator5.1'
    end

    def env_variables
      {
        'GCC_PREPROCESSOR_DEFINITIONS' => 'TEST_MODE=1',
        'CONFIGURATION_BUILD_DIR' => Bwoken.build_path
      }
    end

    def variables_for_cli
      env_variables.map{|key,val| "#{key}=#{val}"}.join(' ')
    end

    def cmd
      "xcodebuild \
        -workspace #{Bwoken.workspace} \
        -scheme #{scheme} \
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

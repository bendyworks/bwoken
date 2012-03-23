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
        'CONFIGURATION_BUILD_DIR' => Bwoken.build_directory
      }
    end

    def cmd
      variables = env_variables.map{|key,val| "#{key}=#{val}"}.join(' ')

      "xcodebuild \
        -workspace #{Bwoken.workspace} \
        -scheme #{scheme} \
        -configuration #{configuration} \
        -sdk #{sdk} \
        #{variables} \
        clean build"
    end

    def compile
      Open3.popen2e(cmd) do |stdin, stdout, wait_thr|

        print "Building"
        out_string = ""

        stdout.each_line do |line|
          out_string << line
          print "."
        end

        exit_status = wait_thr.value
        puts

        if exit_status == 0
          puts
          puts "## Build Successful ##"
          puts
        else
          puts out_string
          raise 'Build failed'
        end
      end
    end
  end
end

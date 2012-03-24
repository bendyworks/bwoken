module Bwoken
  class Script

    attr_accessor :device_family, :path

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

      "mkdir -p #{Bwoken.results_path} && \
        unix_instruments.sh \
        -t #{Bwoken.path_to_automation} \
        #{Bwoken.app} \
        #{variables}"
    end

    def run
      Bwoken::Simulator.device_family = device_family

      exit_status = 0
      Open3.popen2e(cmd) do |stdin, stdout, wait_thr|
        stdout.each_line do |line|
          if line =~ /^\d{4}/
            tokens = line.split(' ')
            tokens.delete_at(2)
            tokens.delete_at(0)
            tokens[1] = tokens[1] =~ /Pass/ ? tokens[1].green : (tokens[1] =~ /Fail/ ? tokens[1].red : tokens[1].yellow)

            highlit = tokens[1].yellow
            if tokens[1] =~ /Pass/
              highlit = tokens[1].green
            elsif tokens[1] =~ /Fail/ || line =~ /Script threw an uncaught JavaScript error/
              exit_status = 1
              highlit = tokens[1].red
            end

            puts "#{tokens[0]} #{highlit}\t#{tokens[2..-1].join(' ')}"
          else
            puts line
          end
        end
      end
      raise 'Build failed' unless exit_status == 0
    end

  end
end

module Bwoken
  class Formatter

    def self.format stdout
      new.format stdout
    end

    def self.on name, &block
      define_method "_on_#{name}_callback" do |line|
        block.call(line)
      end
    end

    def format stdout
      exit_status = 0

      stdout.each_line do |line|
        if line =~ /^\d{4}/
          tokens = line.split(' ')

          if tokens[3] =~ /Pass/
            _on_pass_callback(line)
          elsif tokens[3] =~ /Fail/ || line =~ /Script threw an uncaught JavaScript error/
            exit_status = 1
            _on_fail_callback(line)
          else
            _on_debug_callback(line)
          end
        else
          _on_other_callback(line)
        end
      end
      exit_status
    end

  end
end

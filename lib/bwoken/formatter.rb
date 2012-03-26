module Bwoken
  class Formatter

    class << self
      def format stdout
        new.format stdout
      end

      def on name, &block
        define_method "_on_#{name}_callback" do |line|
          block.call(line)
        end
      end

    end

    def line_demuxer line, exit_status
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
      exit_status
    end

    %w(pass fail debug other).each do |log_level|
      on log_level.to_sym do |line|
        puts line
      end
    end

    def format stdout
      exit_status = 0

      stdout.each_line do |line|
        exit_status = line_demuxer line, exit_status
      end

      exit_status
    end

  end
end

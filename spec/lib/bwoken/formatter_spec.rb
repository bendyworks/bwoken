require 'spec_helper'
require 'bwoken/formatter'

describe Bwoken::Formatter do
  describe '.format' do
    it 'calls format on a new instance' do
      formatter_stub = double('formatter')
      formatter_stub.should_receive(:format).with('foo')
      Bwoken::Formatter.stub(:new => formatter_stub)
      Bwoken::Formatter.format 'foo'
    end
  end

  describe '.on' do
    let(:klass) { klass = Class.new(Bwoken::Formatter) }
    it 'defines an appropriately named instance method' do
      klass.on(:foo) {|line| ''}
      klass.new.should respond_to('_on_foo_callback')
    end

    it 'defines the instance method with the passed-in block' do
      klass.on(:bar) {|line| 42 }
      klass.new._on_bar_callback('').should == 42
    end
  end

  describe 'default log_level formatters' do
    %w(pass fail debug other).each do |log_level|
      specify "for #{log_level} outputs the passed-in line" do
        formatter = Bwoken::Formatter.new
        out = capture_stdout do
          formatter.send("_on_#{log_level}_callback", "- #{log_level}")
        end
        out.should == "- #{log_level}\n"
      end
    end
  end

  describe '#line_demuxer' do

    context 'for a passing line' do
      it 'calls _on_pass_callback' do
        subject.should_receive(:_on_pass_callback).with('1234 a a Pass')
        subject.line_demuxer('1234 a a Pass', 0)
      end
      it 'returns 0' do
        exit_status = 0
        capture_stdout do
          exit_status = subject.line_demuxer('1234 a a Pass', 0)
        end
        exit_status.should == 0
      end
    end

    context 'for a failing line' do
      it 'calls _on_fail_callback' do
        subject.should_receive(:_on_fail_callback).with('1234 a a Fail')
        subject.line_demuxer('1234 a a Fail', 0)
      end
      it 'returns 1' do
        exit_status = 0
        capture_stdout do
          exit_status = subject.line_demuxer('1234 a a Fail', 0)
        end
        exit_status.should == 1
      end
    end

    context 'for a debug line' do
      it 'calls _on_debug_callback' do
        subject.should_receive(:_on_debug_callback).with('1234 a a feh')
        subject.line_demuxer('1234 a a feh', 0)
      end
    end

    context 'for any other line' do
      it 'calls _on_other_callback' do
        subject.should_receive(:_on_other_callback).with('blah blah blah')
        subject.line_demuxer('blah blah blah', 0)
      end
    end
  end

  describe '#format' do
    it 'calls the demuxer for each line' do
      subject.should_receive(:line_demuxer).exactly(3).times
      subject.format("a\nb\nc")
    end

    context 'when no lines fail' do
      it 'returns 0' do
        subject.should_receive(:line_demuxer).with("a\n", 0).ordered.and_return(0)
        subject.should_receive(:line_demuxer).with("b\n", 0).ordered.and_return(0)
        subject.should_receive(:line_demuxer).with("c", 0).ordered.and_return(0)
        subject.format("a\nb\nc").should == 0
      end
    end

    context 'when any line fails' do
      it 'returns 1' do
        subject.should_receive(:line_demuxer).with("a\n", 0).ordered.and_return(0)
        subject.should_receive(:line_demuxer).with("b\n", 0).ordered.and_return(1)
        subject.should_receive(:line_demuxer).with("c", 1).ordered.and_return(1)
        subject.format("a\nb\nc").should == 1
      end
    end
  end

end

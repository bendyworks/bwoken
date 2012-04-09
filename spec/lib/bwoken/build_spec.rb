require 'spec_helper'

require 'stringio'

require 'bwoken/build'

describe Bwoken::Build do

  describe '#scheme' do
    it 'uses the app name' do
      Bwoken.should_receive(:app_name).and_return(:foo)
      subject.scheme.should == :foo
    end
  end

  describe '#configuration' do
    it 'is always Debug' do
      subject.configuration.should == 'Debug'
    end
  end

  describe '#sdk' do
    it 'is always iphonesimulator5.1' do
      subject.sdk.should == 'iphonesimulator5.1'
    end
  end

  describe '#env_variables', :stub_proj_path do
    it 'sets the CONFIGURATION_BUILD_DIR to the build path' do
      Bwoken.stub(:build_path => :foo)
      subject.env_variables['CONFIGURATION_BUILD_DIR'].should == :foo
    end
    it 'sets preprocessor definitions'
  end

  describe '#variables_for_cli' do
    it 'formats variables for xcodebuild' do
      subject.stub(:env_variables => {'foo' => 'bar', 'baz' => 'qux'})
      subject.variables_for_cli.should be_in(['foo=bar baz=qux', 'baz=qux foo=bar'])
    end
  end

  describe '#cmd' do
    it 'returns the xcodebuild command' do
      workspace = stub_out(Bwoken, :workspace, :foo)
      scheme = stub_out(subject, :scheme, :bar)
      configuration = stub_out(subject, :configuration, :baz)
      sdk = stub_out(subject, :sdk, :qux)
      variables_for_cli = stub_out(subject, :variables_for_cli, :quux)

      regexp = /
        xcodebuild\s+
        -workspace\s#{workspace}\s+
        -scheme\s#{scheme}\s+
        -configuration\s#{configuration}\s+
        -sdk\s#{sdk}\s+
        #{variables_for_cli}\s+
        clean\s+build
        /x

      subject.cmd.should match(regexp)
    end
  end

  describe '#compile' do
    let(:compilation_output) { "foo\nbar\nbaz\nqux\nquux" }
    let(:stdin) { StringIO.new }
    let(:stdout) { StringIO.new compilation_output }
    let(:stderr) { StringIO.new }
    let(:raw_exit_code) { 0 }
    let(:wait_thr) { stub(:value => raw_exit_code) }
    let(:formatter) { double('formatter') }

    before { subject.stub(:cmd => 'hi') }

    it "executes 'cmd'" do
      Open3.should_receive(:popen3)
      subject.compile
    end

    it 'formats the output' do
      formatter.should_receive(:format_build).once
      formatter.stub(:build_successful)
      Bwoken.stub(:formatter => formatter)

      Open3.should_receive(:popen3).
        any_number_of_times.
        and_yield(stdin, stdout, stderr, wait_thr)

      stdout = capture_stdout { subject.compile }
    end

    context 'build succeeds' do
      let(:raw_exit_code) { 0 }
      it 'calls the build sussessful formatter' do
        formatter.stub(:format_build)
        formatter.should_receive(:build_successful).once
        Bwoken.stub(:formatter => formatter)

        Open3.should_receive(:popen3).
          any_number_of_times.
          and_yield(stdin, stdout, stderr, wait_thr)

        capture_stdout { subject.compile }
      end
    end

    context 'build fails' do
      let(:raw_exit_code) { 1 }
      it 'calls the build failed formatter' do
        formatter.stub(:format_build)
        formatter.should_receive(:build_failed).once
        Bwoken.stub(:formatter => formatter)

        Open3.should_receive(:popen3).
          any_number_of_times.
          and_yield(stdin, stdout, stderr, wait_thr)

        capture_stdout { subject.compile }
      end

      it 'returns the exit status' do
        formatter.stub(:format_build)
        formatter.stub(:build_failed)
        Bwoken.stub(:formatter => formatter)

        Open3.should_receive(:popen3).
          any_number_of_times.
          and_yield(stdin, stdout, stderr, wait_thr)

        exit_status = 0
        capture_stdout { exit_status = subject.compile }
        exit_status.should == 1
      end
    end
  end

end

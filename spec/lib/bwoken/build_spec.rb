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
    let(:raw_exit_code) { 0 }
    let(:wait_thr) { stub(:value => raw_exit_code) }

    before { subject.stub(:cmd => 'hi') }

    it "executes 'cmd'" do
      Open3.should_receive(:popen2e)
      subject.compile
    end

    it 'formats the output' do
      Open3.should_receive(:popen2e).
        any_number_of_times.
        and_yield(stdin, stdout, wait_thr)

      stdout = capture_stdout { subject.compile }

      stdout.should match /.*Building.*\.\.\.\.\.\s+.*Build Successful/
    end

    context 'build fails' do
      let(:raw_exit_code) { 1 }
      it 'shows all stdout and stderr' do
        Open3.should_receive(:popen2e).
          any_number_of_times.
          and_yield(stdin, stdout, wait_thr)

        stdout = capture_stdout { subject.compile }

        stdout.should match /.*Building.*#{compilation_output}.*Build failed/m
      end
      it 'returns the exit status' do
        Open3.should_receive(:popen2e).
          any_number_of_times.
          and_yield(stdin, stdout, wait_thr)

        exit_status = 0
        capture_stdout { exit_status = subject.compile }
        exit_status.should == 1
      end
    end
  end

end

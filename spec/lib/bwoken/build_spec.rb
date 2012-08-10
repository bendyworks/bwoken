require 'spec_helper'

require 'stringio'

require 'bwoken/build'

describe Bwoken::Build do

  describe '.app_dir', :stub_proj_path do
    it "returns the app's name with the .app suffix" do
      stub_proj_path
      subject.stub(:configuration_build_dir => "#{proj_path}/build/the_sdk")
      Bwoken.stub(:app_name => "FakeProject")
      subject.app_dir.should == "#{proj_path}/build/the_sdk/FakeProject.app"
    end
  end

  describe '.configuration_build_dir', :stub_proj_path do
    it 'returns the build directory with the sdk' do
      subject.stub(:build_path => "#{proj_path}/build")
      subject.stub(:sdk => "an_sdk")
      subject.configuration_build_dir.should == "#{proj_path}/build/an_sdk"
    end
  end

  describe '.build_path', :stub_proj_path do
    it 'returns the build directory' do
      Bwoken.stub(:project_path => proj_path)
      subject.build_path.should == "#{proj_path}/build"
    end
  end

  describe '.scheme' do
    it 'uses the app name' do
      Bwoken.should_receive(:app_name).and_return(:foo)
      subject.scheme.should == :foo
    end
  end

  describe '.configuration' do
    it 'is always Debug' do
      subject.configuration.should == 'Debug'
    end
  end

  describe '.sdk' do
    context 'device connected' do
      before { Bwoken::Device.stub(:connected? => true) }
      its(:sdk) { should == 'iphoneos' }
    end

    context 'device not connected' do
      before { Bwoken::Device.stub(:connected? => false) }
      its(:sdk) { should == 'iphonesimulator' }
    end
  end

  describe '#env_variables', :stub_proj_path do
    it 'sets the BWOKEN_CONFIGURATION_BUILD_DIR to the build path' do
      subject.stub(:build_path => 'foo')
      subject.stub(:sdk => 'bar')
      subject.env_variables['BWOKEN_CONFIGURATION_BUILD_DIR'].should == 'foo/bar'
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
      Bwoken.stub(:xcworkspace => 'foo')
      workspace = stub_out(Bwoken, :workspace_or_project_flag, '-workspace foo')
      workspace_regex = workspace.gsub(/ / ,'\s+')
      scheme = stub_out(subject, :scheme, :bar)
      configuration = stub_out(subject, :configuration, :baz)
      sdk = stub_out(subject, :sdk, :qux)
      xcconfig = stub_out(subject, :xcconfig, :quz)
      variables_for_cli = stub_out(subject, :variables_for_cli, :quux)

      regexp = /
        xcodebuild\s+
        #{workspace_regex}\s+
        -scheme\s#{scheme}\s+
        -configuration\s#{configuration}\s+
        -sdk\s#{sdk}\s+
        -xcconfig\s#{xcconfig}\s+
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

    it 'calls before build starts formatter' do
      formatter.should_receive(:before_build_start).once
      formatter.stub(:format_build)
      formatter.stub(:build_successful)
      Bwoken.stub(:formatter => formatter)
      Open3.stub(:popen3)
      subject.compile
    end

    it "executes 'cmd'" do
      Bwoken.stub_chain(:formatter, :before_build_start)
      Open3.should_receive(:popen3)
      subject.compile
    end

    it 'formats the output' do
      formatter.should_receive(:format_build).once
      formatter.stub(:before_build_start)
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
        formatter.stub(:before_build_start)
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
        formatter.stub(:before_build_start)
        formatter.should_receive(:build_failed).once
        Bwoken.stub(:formatter => formatter)

        Open3.should_receive(:popen3).
          any_number_of_times.
          and_yield(stdin, stdout, stderr, wait_thr)

        capture_stdout { subject.compile }
      end

      it 'returns the exit status' do
        formatter.stub(:format_build)
        formatter.stub(:before_build_start)
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

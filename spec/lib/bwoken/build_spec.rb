require 'spec_helper'

require 'stringio'

require 'bwoken/build'

describe Bwoken::Build do

  before { Bwoken.stub(:app_name => 'app_name') }

  describe '#configuration' do
    it 'is always Debug' do
      subject.configuration.should == 'Debug'
    end
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
      workspace_regex = workspace.gsub(/ /, '\s+')
      scheme = stub_out(subject, :scheme_string, "-scheme bar")
      scheme_regex = scheme.gsub(/ /, '\s+')
      configuration = stub_out(subject, :configuration, :baz)
      sdk = stub_out(subject, :sdk, :qux)
      sdk_version = stub_out(subject, :sdk_version, 123)
      xcconfig = stub_out(subject.class, :xcconfig, :quz)
      variables_for_cli = stub_out(subject, :variables_for_cli, :quux)

      regexp = /
        xcodebuild\s+
        #{workspace_regex}\s+
        #{scheme_regex}\s+
        -configuration\s+#{configuration}\s+
        -sdk\s+#{sdk}#{sdk_version}\s+
        -xcconfig\s+"#{xcconfig}"\s+
        #{variables_for_cli}\s+
        clean\s+build
        /x

      subject.cmd.should match(regexp)
    end
  end

  if RUBY_VERSION == '1.8.7'
    describe '#compile_18' do
      it 'works' do
        pending
      end
    end
  else
    describe '#compile_19_plus' do
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
        subject.compile_19_plus
      end

      it 'formats the output' do
        formatter.should_receive(:format_build).once
        subject.stub(:formatter => formatter)

        Open3.stub(:popen3).and_yield(stdin, stdout, stderr, wait_thr)

        stdout = capture_stdout { subject.compile_19_plus }
      end
    end
  end

  describe '#compile' do
    let(:formatter) { double('formatter') }

    it 'calls before_build_start on formatter' do
      formatter.should_receive(:before_build_start).once
      formatter.stub(:build_successful)
      subject.stub(:formatter => formatter)

      success = [true, '', '']
      subject.stub(:compile_18 => success, :compile_19_plus => success)

      subject.compile
    end

    context 'build succeeds' do
      it 'calls the build sussessful formatter' do
        formatter.stub(:before_build_start)
        formatter.should_receive(:build_successful).with('out')
        subject.stub(:formatter => formatter)

        success = [true, 'out', 'err']
        subject.stub(:compile_18 => success, :compile_19_plus => success)

        subject.compile
      end

      it 'does not raise an error' do
        formatter.stub(:before_build_start)
        formatter.stub(:build_successful)
        subject.stub(:formatter => formatter)

        success = [true, '', '']
        subject.stub(:compile_18 => success, :compile_19_plus => success)

        expect { subject.compile }.not_to raise_error
      end
    end

    context 'build fails' do
      it 'calls the build failed formatter' do
        formatter.stub(:before_build_start)
        formatter.should_receive(:build_failed).with('out', 'err')
        subject.stub(:formatter => formatter)

        failure = [false, 'out', 'err']
        subject.stub(:compile_18 => failure, :compile_19_plus => failure)

        subject.compile rescue nil
      end

      it 'raises BuildFailedError' do
        formatter.stub(:before_build_start)
        formatter.stub(:build_failed)
        subject.stub(:formatter => formatter)

        failure = [false, '', '']
        subject.stub(:compile_18 => failure, :compile_19_plus => failure)

        expect { subject.compile }.to raise_error(Bwoken::BuildFailedError)
      end
    end
  end

end

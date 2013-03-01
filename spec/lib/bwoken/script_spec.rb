require 'spec_helper'

require 'bwoken/script'

module Bwoken
  class Simulator; end
end


describe Bwoken::Script do

  describe '.run_all' do
    it 'sets the device_family once' do
      Bwoken::Simulator.should_receive(:device_family=).with('foo').once
      Bwoken::Script.stub(:run)
      Bwoken::Script.stub(:test_files => %w(a b))
      Bwoken.stub(:test_suite_path)
      Bwoken::Script.run_all 'foo'
    end

    it "runs all scripts in the device_family's path" do
      Bwoken::Simulator.stub(:device_family=)
      Bwoken::Script.stub(:run)
      Bwoken.stub(:test_suite_path)
      Bwoken::Script.stub(:test_files => %w(a b))
      Bwoken::Script.should_receive(:run).with('a').once.ordered
      Bwoken::Script.should_receive(:run).with('b').once.ordered
      Bwoken::Script.run_all 'foo'
    end

  end

  describe '.run_one' do
    let(:feature) { 'foo' }
    it 'sets the simulator based on passed in device' do
      Bwoken::Simulator.should_receive(:device_family=).with('ipad').once
      Bwoken.stub(:test_suite_path => 'suite')
      Bwoken::Script.stub(:run)
      Bwoken::Script.run_one feature, 'ipad'
    end

    it 'runs the one script' do
      Bwoken::Simulator.stub(:device_family=)
      Bwoken.stub(:test_suite_path => 'suite')
      Bwoken::Script.should_receive(:run).with("suite/ipad/#{feature}.js").once
      Bwoken::Script.run_one feature, 'ipad'
    end
  end

  describe '.test_files' do
    it 'returns all test files minus helpers' do
      Bwoken.stub(:test_suite_path)
      Dir.should_receive(:[]).once.ordered.and_return(%w(foo/a foo/helpers/b foo/c))
      Dir.should_receive(:[]).once.ordered.and_return(%w(foo/helpers/b))
      Bwoken::Script.test_files('foo').should == %w(foo/a foo/c)
    end
  end

  describe '.run' do

    it 'instantiates a script object' do
      script_double = double('script', :path= => nil, :run => nil)
      Bwoken::Script.should_receive(:new).and_return(script_double)
      Bwoken::Script.run ''
    end

    it 'sets the path' do
      script_double = double('script', :run => nil)
      script_double.should_receive(:path=)
      Bwoken::Script.stub(:new => script_double)
      Bwoken::Script.run ''
    end

    it 'calls run after configuring the path' do
      script_double = double('script', :run => nil)
      script_double.should_receive(:path=).once.ordered
      script_double.should_receive(:run).once.ordered

      Bwoken::Script.should_receive(:new).and_return(script_double)
      Bwoken::Script.run ''
    end
  end

  describe '#env_variables' do
    it 'returns a hash with UIASCRIPT set to #path' do
      Bwoken.stub(:results_path => 'foo')
      subject.path = 'bar'
      subject.env_variables['UIASCRIPT'].should == 'bar'
    end

    it 'returns a hash with UIARESULTSPATH set to Bwoken.results_path' do
      Bwoken.stub(:results_path => 'foo')
      subject.env_variables['UIARESULTSPATH'].should == 'foo'
    end

  end

  describe '#env_variables_for_cli' do
    it 'preps the variables for cli use' do
      subject.path = 'foo'
      Bwoken.stub(:results_path => 'bar')

      expected = ['-e UIASCRIPT foo -e UIARESULTSPATH bar', '-e UIARESULTSPATH bar -e UIASCRIPT foo']
      subject.env_variables_for_cli.should be_in(expected)
    end
  end

  describe '.trace_file_path' do
    it 'points to the trace path inside <bwoken_tmp>' do
      tmp_path = stub_out(Bwoken, :tmp_path, 'bazzle')
      subject.class.trace_file_path.should == "#{tmp_path}/trace"
    end

  end


  describe '#cmd' do
    let!(:trace_file_path) { stub_out(subject.class, :trace_file_path, 'trace_file_path') }
    let!(:path_to_automation_template) { stub_out(Bwoken, :path_to_automation_template, 'foo') }
    let!(:env_variables_for_cli) { stub_out(subject, :env_variables_for_cli, 'baz') }

    let(:app_dir) { 'bar' }
    let(:build) { mock(Bwoken::Build, :app_dir => app_dir) }
    let(:regexp) do
      /
        unix_instruments\.sh\s+
        #{expected_device_flag_regexp}
        -D\s#{trace_file_path}\s+
        -t\s#{path_to_automation_template}\s+
        #{app_dir}\s+
        #{env_variables_for_cli}/x
    end

    before { Bwoken::Build.stub(:new => build) }

    shared_examples 'returns the correct unix_instruments command' do
      it 'matches the regexp' do
        subject.cmd.should match regexp
      end
    end

    context 'when a device is connected' do
      let(:uuid) { 'abcdef1234567890' }
      before do
        Bwoken::Device.stub(:connected? => true)
        Bwoken::Device.stub(:uuid => uuid)
      end

      context 'without overriding from command-line' do
        let(:expected_device_flag_regexp) { "-w\\s#{uuid}\\s+" }
        it_behaves_like 'returns the correct unix_instruments command'
      end

      context 'when overriding from command-line' do
        let(:expected_device_flag_regexp) { '' }
        before { ENV.stub(:[]).with('SIMULATOR').and_return('TRUE') }
        it_behaves_like 'returns the correct unix_instruments command'
      end
    end

    context 'when a device is not connected' do
      before { Bwoken::Device.stub(:connected? => false) }
      let(:expected_device_flag_regexp) { '' }
      it_behaves_like 'returns the correct unix_instruments command'
    end
  end

  describe '#make_results_path_dir' do
    it 'creates the results_path directory' do
      Bwoken.stub(:results_path => 'foo')
      FileUtils.should_receive(:mkdir_p).with('foo')
      subject.make_results_path_dir
    end
  end

  describe '#run' do
    it 'calls before script run with path on the formatter' do
      path = "foo/bar"
      subject.stub(:path => path)
      formatter = double('formatter')
      formatter.should_receive(:before_script_run).once.with(path)
      Bwoken.stub(:formatter => formatter)
      subject.stub(:cmd)
      subject.stub(:make_results_path_dir)
      Open3.stub(:popen3)
      subject.run
    end

    it 'runs cmd through Open3.popen3' do
      Bwoken.stub_chain(:formatter, :before_script_run)
      subject.stub(:cmd => 'cmd')
      Open3.should_receive(:popen3).with('cmd')

      subject.stub(:make_results_path_dir)

      subject.run
    end

    it 'formats the output with the bwoken formatter' do
      formatter = double('formatter')
      formatter.stub(:before_script_run)
      formatter.should_receive(:format).with("a\nb\nc").and_return(0)
      Bwoken.stub(:formatter).and_return(formatter)

      subject.stub(:make_results_path_dir)
      subject.stub(:cmd)

      Open3.should_receive(:popen3).
        any_number_of_times.
        and_yield('', "a\nb\nc", '', '')

      subject.run
    end

    it 'raises when exit_status is non-zero' do
      formatter = double('formatter')
      formatter.stub(:before_script_run)
      formatter.should_receive(:format).with("a\nb\nc").and_return(1)
      Bwoken.stub(:formatter).and_return(formatter)

      subject.stub(:make_results_path_dir)
      subject.stub(:cmd)

      Open3.should_receive(:popen3).
        any_number_of_times.
        and_yield('', "a\nb\nc", '', '')

      lambda do
        subject.run
      end.should raise_error(Bwoken::ScriptFailedError)
    end

  end


end

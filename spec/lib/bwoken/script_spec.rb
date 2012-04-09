require 'spec_helper'

require 'bwoken/script'

module Bwoken
  class ColorfulFormatter; end
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
    let(:script) { 'ipad/foo' }
    it 'sets the simulator based on beginning of path' do
      Bwoken::Simulator.should_receive(:device_family=).with('ipad').once
      Bwoken.stub(:test_suite_path => 'suite')
      Bwoken::Script.stub(:run)
      Bwoken::Script.run_one script
    end

    it 'runs the one script' do
      Bwoken::Simulator.stub(:device_family=)
      Bwoken.stub(:test_suite_path => 'suite')
      Bwoken::Script.should_receive(:run).with("suite/#{script}.js").once
      Bwoken::Script.run_one script
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
    it 'returns the unix_instruments command' do
      path_to_automation_template = stub_out(Bwoken, :path_to_automation_template, 'foo')
      trace_file_path = stub_out(subject.class, :trace_file_path, 'trace_file_path')
      app_dir = stub_out(Bwoken, :app_dir, 'bar')
      env_variables_for_cli = stub_out(subject, :env_variables_for_cli, 'baz')

      regexp = /
        unix_instruments\.sh\s+
        -D\s#{trace_file_path}\s+
        -t\s#{path_to_automation_template}\s+
        #{app_dir}\s+
        #{env_variables_for_cli}/x

      subject.cmd.should match regexp
    end
  end

  describe '#formatter' do
    it 'returns Bwoken::ColorfulFormatter' do
      subject.formatter.should == Bwoken::ColorfulFormatter
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
    it 'runs cmd through Open3.popen3' do
      subject.stub(:cmd => 'cmd')
      Open3.should_receive(:popen3).with('cmd')

      subject.stub(:make_results_path_dir)

      subject.run
    end

    it 'formats the output with ColorfulFormatter' do
      formatter = double('formatter')
      formatter.should_receive(:format).with("a\nb\nc").and_return(0)
      subject.stub(:formatter => formatter)

      subject.stub(:make_results_path_dir)
      subject.stub(:cmd)

      Open3.should_receive(:popen3).
        any_number_of_times.
        and_yield('', "a\nb\nc", '', '')

      subject.run
    end

    it 'raises when exit_status is non-zero' do
      formatter = double('formatter')
      formatter.should_receive(:format).with("a\nb\nc").and_return(1)
      subject.stub(:formatter => formatter)

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

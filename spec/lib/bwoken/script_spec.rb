require 'spec_helper'

require 'bwoken/script'

module Bwoken
  class ColorfulFormatter; end
  class Simulator; end
end


describe Bwoken::Script do

  describe '.run' do
    it 'instantiates a script object' do
      script_double = double('script', :run => nil)
      Bwoken::Script.should_receive(:new).and_return(script_double)
      Bwoken::Script.run {|_| '' }
    end

    it 'yields the instantiated script object' do
      script_double = double('script', :run => nil)
      Bwoken::Script.should_receive(:new).and_return(script_double)
      Bwoken::Script.run {|script| script.should == script_double }
    end

    it 'calls run after configuring via yield' do
      script_double = double('script', :run => nil)
      Bwoken::Script.should_receive(:new).and_return(script_double)
      Bwoken::Script.run {|script| script.should_receive(:run) }
    end
  end

  describe '#device_family' do
    context 'with FAMILY set in ENV' do
      it 'sets @device_family to ENV["FAMILY"]' do
        ENV["FAMILY"] = 'ipad'
        subject.device_family.should == 'ipad'
        ENV.delete 'FAMILY'
      end
    end

    context 'by default' do
      it 'sets @device_family to "iphone"' do
        subject.device_family.should == 'iphone'
      end
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
      subject.env_variables_for_cli.should == '-e UIASCRIPT foo -e UIARESULTSPATH bar'
    end
  end

  describe '#cmd' do
    it 'returns the unix_instruments command' do
      path_to_automation = stub_out(Bwoken, :path_to_automation, 'foo')
      app_dir = stub_out(Bwoken, :app_dir, 'bar')
      env_variables_for_cli = stub_out(subject, :env_variables_for_cli, 'baz')

      regexp = /
        unix_instruments\.sh\s+
        -t\s#{path_to_automation}\s+
        #{app_dir}\s+
        #{env_variables_for_cli}/x

      subject.cmd.should match regexp
    end
  end

  describe '#simulator' do
    it 'returns the simulator class' do
      subject.simulator.should == Bwoken::Simulator
    end
  end

  describe '#set_simulator_device_family!' do
    it 'sets the simulator device_family' do
      subject.device_family = 'foo'
      subject.simulator.should_receive(:device_family=).with('foo')
      subject.set_simulator_device_family!
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
    it 'sets the device_family on Simulator' do
      subject.should_receive(:set_simulator_device_family!)

      subject.stub(:make_results_path_dir)
      subject.stub(:cmd)
      Open3.stub(:popen2e)

      subject.run
    end

    it 'runs cmd through Open3.popen2e' do
      subject.stub(:cmd => 'cmd')
      Open3.should_receive(:popen2e).with('cmd')

      subject.stub(:set_simulator_device_family!)
      subject.stub(:make_results_path_dir)

      subject.run
    end

    it 'formats the output with ColorfulFormatter' do
      formatter = double('formatter')
      formatter.should_receive(:format).with("a\nb\nc").and_return(0)
      subject.stub(:formatter => formatter)

      subject.stub(:set_simulator_device_family!)
      subject.stub(:make_results_path_dir)
      subject.stub(:cmd)

      Open3.should_receive(:popen2e).
        any_number_of_times.
        and_yield('', "a\nb\nc", '')

      subject.run
    end

    it 'raises when exit_status is non-zero' do
      formatter = double('formatter')
      formatter.should_receive(:format).with("a\nb\nc").and_return(1)
      subject.stub(:formatter => formatter)

      subject.stub(:set_simulator_device_family!)
      subject.stub(:make_results_path_dir)
      subject.stub(:cmd)

      Open3.should_receive(:popen2e).
        any_number_of_times.
        and_yield('', "a\nb\nc", '')

      lambda do
        subject.run
      end.should raise_error(RuntimeError)
    end

  end


end

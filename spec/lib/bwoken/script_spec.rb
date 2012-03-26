require 'bwoken/script'

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
      it 'sets @device_family to ENV["FAMILY"]'
    end

    context 'by default' do
      it 'sets @device_family to "iphone"'
    end
  end

  describe '#env_variables' do
    it 'returns a hash with UIASCRIPT set to #path'
    it 'returns a hash with UIRESULTSPATH set to Bwoken.results_path'
  end

  describe '#variables_for_cli' do
    it 'preps the variables for cli use'
  end

  describe '#cmd' do
    it 'returns the unix_instruments command'
  end

  describe '#run' do
    it 'sets the device_family on Simulator'
    context 'when the results_path directory does not exist' do
      it 'creates the results_path directory'
    end
    it 'runs cmd through Open3.popen2e'
    it 'formats the output with ColorfulFormatter'
    it 'raises when exit_status is non-zero'
  end


end

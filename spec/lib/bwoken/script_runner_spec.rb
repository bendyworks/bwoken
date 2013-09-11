require 'spec_helper'

require 'bwoken/script_runner'
require 'bwoken/device_runner'

describe Bwoken::ScriptRunner do

  describe '#execute' do
    it 'executes for each family' do
      subject.stub(:chosen_families).and_return(%w(a b))
      subject.should_receive(:execute_for_family).with('a').ordered
      subject.should_receive(:execute_for_family).with('b').ordered
      subject.execute
    end
  end

  describe '#execute_for_family' do
    it 'gets the appropriate device runner' do
      subject.should_receive(:runner_for_family).with('a').and_return(stub(:execute => lambda {}))
      subject.execute_for_family('a')
    end

    it 'calls execute on a device runner' do
      runner_stub = stub
      runner_stub.should_receive(:execute)
      subject.stub(:runner_for_family).and_return(runner_stub)
      subject.execute_for_family('a')
    end
  end

  describe '#chosen_families' do
    shared_examples "for wanting both families" do |family|
      subject do
        Bwoken::ScriptRunner.new {|sr| sr.family = family }
      end
      it 'returns an array of "iphone" and "ipad"' do
        expect(subject.chosen_families).to eq(%w(iphone ipad))
      end
    end

    context 'when family is blank-ish' do
      [[], nil].each do |family|
        include_examples 'for wanting both families', family
      end
    end

    context 'when a device family' do
      let(:fam) { 'ipad' }
      subject do
        Bwoken::ScriptRunner.new {|sr| sr.family = fam }
      end

      it 'returns an array of that family' do
        expect(subject.chosen_families).to eq([fam])
      end
    end
  end

end

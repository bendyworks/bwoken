require 'spec_helper'

require 'bwoken/simulator_runner'

describe Bwoken::SimulatorRunner do

  describe '#script_filenames' do
    shared_examples 'for not focused' do
      it 'returns all scripts' do
        subject.should_receive(:all_test_files).and_return('y')
        expect(subject.script_filenames).to eq('y')
      end
    end

    context 'focus not defined' do
      include_examples 'for not focused'
    end

    context 'focus is empty array' do
      before { subject.focus = [] }
      include_examples 'for not focused'
    end

    context 'focus set' do
      it 'returns focused tests' do
        subject.focus = ['a']
        subject.should_receive(:test_files_from_feature_names).and_return('y')
        expect(subject.script_filenames).to eq('y')
      end
    end
  end

end

require 'bwoken/coffeescript/import_string'

describe Bwoken::Coffeescript::ImportString do
  let(:string) { '#import foo.js' }
  subject { Bwoken::Coffeescript::ImportString.new(string) }

  describe '#parse' do
    it 'does not affect @string' do
      subject.parse
      expect(subject.instance_variable_get('@string')).to eq(string)
    end
  end

  its(:to_s) { should == string }
end

require 'bwoken/device'

describe Bwoken::Device do
  subject { Bwoken::Device }

  describe '.want_simulator?' do
    context 'set to true from command line' do
      it 'is true' do
        ENV.stub(:[]).with('SIMULATOR').and_return('TRUE')
        subject.want_simulator?.should be_true
      end
    end
    context 'not set from command line' do
      it 'is false' do
        subject.want_simulator?.should be_false
      end
    end
  end

  describe '.connected?' do
    context 'device connected' do
      it 'is true' do
        subject.stub(:uuid => 'asdfasefasdfasd')
        subject.should be_connected
      end
    end
    context 'device not connected' do
      it 'is false' do
        subject.stub(:uuid => nil)
        subject.should_not be_connected
      end
    end
  end
end


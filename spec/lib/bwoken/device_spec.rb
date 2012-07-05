require 'bwoken/device'

describe Bwoken::Device do
  subject { Bwoken::Device }

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


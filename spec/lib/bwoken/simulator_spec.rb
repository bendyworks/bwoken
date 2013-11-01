require 'bwoken/simulator'

describe Bwoken::Simulator do
  describe '.device_family=' do
    it 'updates the plist in the correct order' do
      Bwoken::Simulator.should_receive(:update_device_family_in_plist).with(:delete_array).ordered
      Bwoken::Simulator.should_receive(:update_device_family_in_plist).with(:add_array).ordered
      Bwoken::Simulator.should_receive(:update_device_family_in_plist).with(:add_scalar, 'foo').ordered
      Bwoken::Simulator.device_family = 'foo'
    end
  end

  describe '.update_device_family_in_plist' do
    before do
      Bwoken::Simulator.stub(:plist_buddy => 'plistbuddy')
      Bwoken::Simulator.stub(:plist_file => 'plist_file')
    end

    context 'when deleting the device family array' do
      it 'calls PlistBuddy with the correct args' do
        Kernel.should_receive(:system).with("plistbuddy -c 'Delete :UIDeviceFamily' \"plist_file\"")
        Bwoken::Simulator.update_device_family_in_plist :delete_array
      end
    end

    context 'when creating the device family array' do
      it 'calls PlistBuddy with the correct args' do
        Kernel.should_receive(:system).with("plistbuddy -c 'Add :UIDeviceFamily array' \"plist_file\"")
        Bwoken::Simulator.update_device_family_in_plist :add_array
      end
    end

    context 'when adding to the device family array' do
      context 'for iPhone' do
        it 'calls PlistBuddy with the correct args' do
          Kernel.should_receive(:system).with("plistbuddy -c 'Add :UIDeviceFamily:0 integer 1' \"plist_file\"")
          Bwoken::Simulator.update_device_family_in_plist :add_scalar, 'iphone'
        end
      end

      context 'for iPad' do
        it 'calls PlistBuddy with the correct args' do
          Kernel.should_receive(:system).with("plistbuddy -c 'Add :UIDeviceFamily:0 integer 2' \"plist_file\"")
          Bwoken::Simulator.update_device_family_in_plist :add_scalar, 'ipad'
        end
      end

      context 'for universal' do
        it 'calls PlistBuddy with the correct args' do
          Kernel.should_receive(:system).with("plistbuddy -c 'Add :UIDeviceFamily:0 integer 1' \"plist_file\"")
          Kernel.should_receive(:system).with("plistbuddy -c 'Add :UIDeviceFamily:0 integer 2' \"plist_file\"")
          Bwoken::Simulator.update_device_family_in_plist :add_scalar, 'universal'
        end
      end

    end
  end

end


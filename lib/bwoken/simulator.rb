module Bwoken
  class Simulator
    def self.device_family= device_family
      device_family_id = device_family == 'iphone' ? 1 : 2
      plistbuddy = '/usr/libexec/PlistBuddy'
      plist_file = "#{Bwoken.app_dir}/Info.plist"
      system "#{plistbuddy} -c 'Delete :UIDeviceFamily' #{plist_file}"
      system "#{plistbuddy} -c 'Add :UIDeviceFamily array' #{plist_file}"
      system "#{plistbuddy} -c 'Add :UIDeviceFamily:0 integer #{device_family_id}' #{plist_file}"
    end
  end
end

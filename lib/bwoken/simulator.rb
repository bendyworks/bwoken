module Bwoken
  class Simulator

    def self.plist_buddy; '/usr/libexec/PlistBuddy'; end
    def self.plist_file; "#{Bwoken::Build.app_dir(true)}/Info.plist"; end

    def self.device_family= device_family
      update_device_family_in_plist :delete_array
      update_device_family_in_plist :add_array
      update_device_family_in_plist :add_scalar, device_family
    end

    def self.update_device_family_in_plist action, args = nil
      system_cmd = lambda {|command| Kernel.system "#{plist_buddy} -c '#{command}' \"#{plist_file}\"" }

      case action
      when :delete_array then system_cmd['Delete :UIDeviceFamily']
      when :add_array    then system_cmd['Add :UIDeviceFamily array']
      when :add_scalar
        command = lambda {|scalar| "Add :UIDeviceFamily:0 integer #{scalar == 'iphone' ? 1 : 2}"}

        case args
        when /iphone/i
          system_cmd[command['iphone']]
        when /ipad/i
          system_cmd[command['ipad']]
        when /universal/i
          system_cmd[command['ipad']]
          system_cmd[command['iphone']]
        end

      end
    end

  end
end

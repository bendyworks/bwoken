module Bwoken
  class Device
    def self.connected?
      self.uuid ? true : false
    end

    def self.uuid
      ioreg = `ioreg -w 0 -rc IOUSBDevice -k SupportsIPhoneOS`
      ioreg[/"USB Serial Number" = "([0-9a-z]+)"/]
    end

  end
end

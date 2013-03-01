module Bwoken
  class Device
    class << self

      def should_use_simulator?
        want_simulator? || ! connected?
      end

      def want_simulator?
        ENV['SIMULATOR'] && ENV['SIMULATOR'].downcase == 'true'
      end

      def connected?
        self.uuid ? true : false
      end

      def uuid
        ioreg = `ioreg -w 0 -rc IOUSBDevice -k SupportsIPhoneOS`
        ioreg[/"USB Serial Number" = "([0-9a-z]+)"/] && $1
      end

    end

  end
end

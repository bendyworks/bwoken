require 'pry'

module Bwoken
  module CLI
    class Run
      # opts - A slop command object (acts like super-hash)
      #        :simulator - should force simulator use (default: nil)
      #        :device    - enum of [nil, 'iphone', 'ipad'] (case-insensitive)
      #        :scheme    - custom scheme (default: nil)
      #        :flags     - custom build flag array (default: [])
      #        :formatter - custom formatter (default: 'colorful')
      #        :focus     - which tests to run (default: [], meaning "all")
      def self.run opts
      end
    end
  end
end

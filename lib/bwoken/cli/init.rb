require 'fileutils'
require 'slop'

module Bwoken
  module CLI
    class Init

      class << self

        def help_banner
          <<BANNER
Initialize your UIAutomation project.


== Options ==
BANNER
        end
      end

      # opts - A slop command object (acts like super-hash)
      #        There are currently no options available
      def initialize opts
        # opts = opts.to_hash if opts.is_a?(Slop)
      end

      def run
        directory 'integration/coffeescript/iphone'
        directory 'integration/coffeescript/ipad'
        directory 'integration/javascript'
        directory 'integration/tmp/results'
        template 'integration/coffeescript/iphone/example.coffee'
        template 'integration/coffeescript/ipad/example.coffee'
        template 'integration/javascript/example_vendor.js'
      end

      def directory dirname
        FileUtils.mkdir_p dirname
      end

      def template filename
        FileUtils.cp \
          File.expand_path("../templates/#{filename}", __FILE__),
          filename
      end

    end
  end
end

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
      #        Only allowed option is 'integration-path' which should
      #        have defaulted to 'integration'
      def initialize opts
        opts = opts.to_hash if opts.is_a?(Slop)
        Bwoken.integration_path = opts[:'integration-path']
      end

      def run
        directory "coffeescript/iphone"
        directory "coffeescript/ipad"
        directory "javascript"
        directory "tmp/results"
        template "coffeescript/iphone/example.coffee"
        template "coffeescript/ipad/example.coffee"
        template "javascript/example_vendor.js"
      end

      def directory dirname
        FileUtils.mkdir_p "#{Bwoken.integration_path}/#{dirname}"
      end

      def template filename
        source = File.expand_path("../templates/#{filename}", __FILE__)
        destination = "#{Bwoken.integration_path}/#{filename}"
        FileUtils.cp source, destination
      end

    end
  end
end

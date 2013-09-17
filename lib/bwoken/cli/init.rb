require 'fileutils'
require 'slop'

module Bwoken
  module CLI
    class Init

      class << self

        def help_banner
          <<-BANNER
Initialize your UIAutomation project.


== Options ==
BANNER
        end
      end

      attr_accessor :options

      # opts - A slop command object (acts like super-hash)
      #        There are currently no options available
      def initialize opts
        opts = opts.to_hash if opts.is_a?(Slop)
        self.options = opts.to_hash
      end

      def run
        integration_dir = options[:'integration-path']
        directory "#{integration_dir}/coffeescript/iphone"
        directory "#{integration_dir}/coffeescript/ipad"
        directory "#{integration_dir}/javascript"
        directory "#{integration_dir}/tmp/results"
        template "#{integration_dir}/coffeescript/iphone/example.coffee"
        template "#{integration_dir}/coffeescript/ipad/example.coffee"
        template "#{integration_dir}/javascript/example_vendor.js"
      end

      def directory dirname
        FileUtils.mkdir_p dirname
      end

      def template filename
        fixed_filename = "integration" + filename[options[:'integration-path'].length..-1]
        FileUtils.cp \
          File.expand_path("../templates/#{fixed_filename}", __FILE__),
          filename
      end

    end
  end
end

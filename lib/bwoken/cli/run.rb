require 'slop'
require 'rake/file_list'

module Bwoken
  module CLI
    class Run

      class << self
        def help_banner
          <<BANNER
Run your tests. If you don't specify which tests, bwoken will run them all

    bwoken run --simulator # runs all tests in the simulator

You can specify a device type if you only want to run, say, iPad tests:

    bwoken run --device ipad

If you only want to run a specific test, you can focus on it:

    bwoken run --focus login # runs iPhone and iPad tests named "login"


== Options ==
BANNER
        end
        # opts - A slop command object (acts like super-hash)
        #        :simulator - should force simulator use (default: nil)
        #        :device    - enum of [nil, 'iphone', 'ipad'] (case-insensitive)
        #        :scheme    - custom scheme (default: nil)
        #        :flags     - custom build flag array (default: [])
        #        :formatter - custom formatter (default: 'colorful')
        #        :focus     - which tests to run (default: [], meaning "all")
        #        :clean     - remove any temporary products
        #        :clobber   - remove any generated file
        def run opts
          clobber if opts.clobber?
          clean if opts.clean?

        end

        def all device_families = Bwoken.DEVICE_FAMILIES
          Array(device_families).each do |device_family|
            Bwoken::Script.run_all device_family
          end
        end

        def focus focused, device_families = 'all'
          Array(device_families).each do |device_family|
            Bwoken::Script.run_focused Array(focused), device_family
          end
        end

        def coffeescript
          #COMPILED_COFFEE.zip(COFFEESCRIPTS).each do |target, source|
            #containing_dir = target.pathmap('%d')
            #directory containing_dir
            #file target => [containing_dir, source] do
              #Bwoken::Coffeescript.compile source, target
            #end
          #end

          #COPIED_JAVASCRIPTS.zip(JAVASCRIPTS).each do |target, source|
            #containing_dir = target.pathmap('%d')
            #directory containing_dir
            #file target => [containing_dir, source] do
              #sh "cp #{source} #{target}"
            #end
          #end
        end

        def compile; end

        def clobber; end
        def clean; end

      private

        COFFEESCRIPTS      = FileList['integration/coffeescript/**/*.coffee']
        COMPILED_COFFEE    = COFFEESCRIPTS.pathmap('%{^integration/coffeescript,integration/tmp/javascript}d/%n.js')
        JAVASCRIPTS        = FileList['integration/javascript/**/*.js']
        COPIED_JAVASCRIPTS = JAVASCRIPTS.pathmap('%{^integration/javascript,integration/tmp/javascript}d/%f')

      end
    end
  end
end

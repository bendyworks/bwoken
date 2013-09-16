require 'slop'
require 'rake/file_list'
require 'fileutils'

require 'bwoken'
require 'bwoken/build'
require 'bwoken/coffeescript'
require 'bwoken/device'
#TODO: make formatters dynamically loadable during runtime
require 'bwoken/formatter'
require 'bwoken/formatters/passthru_formatter'
require 'bwoken/formatters/colorful_formatter'
require 'bwoken/script_runner'

module Bwoken
  module CLI
    class Test

      def self.help_banner
        <<-BANNER
Run your tests. If you don't specify which tests, bwoken will run them all

  bwoken test --simulator # runs all tests in the simulator

You can specify a device family if you only want to run, say, iPad tests:

  bwoken test --family ipad

If you only want to run a specific test, you can focus on it:

  bwoken test --focus login # runs iPhone and iPad tests named "login"


== Options ==
BANNER
      end

      attr_accessor :options

      # opts - A slop command object (acts like super-hash)
      #       :clobber    - remove all generated files, including iOS build
      #       :family     - enum of [nil, 'iphone', 'ipad'] (case-insensitive)
      #       :flags      - custom build flag array (default: []) TODO: not yet implmented
      #       :focus      - which tests to run (default: [], meaning "all")
      #       :formatter  - custom formatter (default: 'colorful')
      #       :scheme     - custom scheme (default: nil)
      #       :simulator  - should force simulator use (default: nil)
      #       :skip-build - do not build the iOS binary
      #       :verbose    - be verbose
      #       :integration-path - the base directory for all the integration files
      #       :product-name - the name of the generated .app file if it is different from the name of the project/workspace
      def initialize opts
        opts = opts.to_hash if opts.is_a?(Slop)
        self.options = opts.to_hash.tap do |o|
          o[:formatter] = 'passthru' if o[:verbose]
          o[:formatter] = select_formatter(o[:formatter])
          o[:simulator] = use_simulator?(o[:simulator])
          o[:family] = o[:family]
        end

        Bwoken.integration_path = options[:'integration-path']
      end

      def run
        clobber if options[:clobber]
        compile unless options[:'skip-build']
        clean
        transpile
        test
      end

      def compile
        Build.new do |b|
          #b.flags = opts.flags #TODO: implement
          b.formatter = options[:formatter]
          b.scheme = options[:scheme] if options[:scheme]
          b.simulator = options[:simulator]
        end.compile
      end

      def transpile
        integration_dir = options[:'integration-path']
        coffeescripts      = Rake::FileList["#{integration_dir}/coffeescript/**/*.coffee"]
        compiled_coffee    = coffeescripts.pathmap("%{^#{integration_dir}/coffeescript,#{integration_dir}/tmp/javascript}d/%n.js")
        javascripts        = Rake::FileList["#{integration_dir}/javascript/**/*.js"]
        copied_javascripts = javascripts.pathmap("%{^#{integration_dir}/javascript,#{integration_dir}/tmp/javascript}d/%f")

        compiled_coffee.zip(coffeescripts).each do |target, source|
          containing_dir = target.pathmap('%d')
          ensure_directory containing_dir
          Bwoken::Coffeescript.compile source, target
        end

        copied_javascripts.zip(javascripts).each do |target, source|
          containing_dir = target.pathmap('%d')
          ensure_directory containing_dir
          FileUtils.cp source, target
        end
      end

      def test
        Bwoken.app_name = options[:'product-name']

        ScriptRunner.new do |s|
          s.app_dir = Build.app_dir(options[:simulator])
          s.family = options[:family]
          s.focus = options[:focus]
          s.formatter = options[:formatter]
          s.simulator = options[:simulator]
        end.execute
      end

      def clobber
        FileUtils.rm_rf Bwoken.tmp_path
        FileUtils.rm_rf Bwoken::Build.build_path
      end

      def clean
        FileUtils.rm_rf Bwoken.test_suite_path
      end

      def select_formatter formatter_name
        case formatter_name
        when 'passthru' then Bwoken::PassthruFormatter.new
        else Bwoken::ColorfulFormatter.new
        end
      end

      def use_simulator? want_forced_simulator
        want_forced_simulator || ! Bwoken::Device.connected?
      end

      def ensure_directory dir
        FileUtils.mkdir_p dir
      end

    end

  end
end

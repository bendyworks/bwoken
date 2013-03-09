require 'fileutils'
require File.expand_path('../import_string', __FILE__)

module Bwoken
  class Coffeescript
    class GithubImportString < ImportString
      attr_reader :repo_name, :file_path

      def initialize string
        @string = string
        parse_parts
      end

      def parse
        ensure_github
      end

      def to_s
        %Q|#import "#{repo_path}/#{file_path}"|
      end

    private

      # this is kinda gross. Key thing to recognize is that we're whitelisting
      # the account name, project name, and filename. We'll eventually be escaping
      # out to Kernel#`, so we shouldn't be allowing all characters (eg, ';' would be BAD)
      def parse_parts
        importing = @string.match(%r{\A\s*#github\s+['"]?\b([^'"]*)['"]?}i)[1]
        @repo_name, @file_path = importing.match(%r{([-a-z_0-9]+/[-a-z_0-9]+)/([-a-z_0-9/\.]*)})[1..2]
      end

      def ensure_github
        if !repo_exists? || ENV['FORCE_GITHUB'] == 'true'
          clean_repo
          download_repo
        end
      end

      def clean_repo
        delete_repo if repo_exists?
      end

      def delete_repo
        FileUtils.rm_rf(repo_path)
      end

      def repo_path
        File.join(Bwoken.path, 'github', repo_name)
      end

      def repo_exists?
        File.exist? repo_path
      end

      def download_repo
        prepare_repo_path
        clone_repo
        delete_dot_git
      end

      def prepare_repo_path
        FileUtils.mkdir_p File.dirname(repo_path)
      end

      def clone_repo
        `git clone --single-branch --branch master git://github.com/#{repo_name} #{repo_path}`
      end

      def delete_dot_git
        FileUtils.rm_rf File.join(repo_path, '.git')
      end

    end
  end
end

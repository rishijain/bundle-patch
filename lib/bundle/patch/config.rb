# lib/bundle/patch/config.rb
require "optparse"

module Bundle
  module Patch
    class Config
      attr_reader :dry_run, :mode, :skip_bundle_install

      def initialize(dry_run: false, mode: "patch", skip_bundle_install: false)
        @dry_run = dry_run
        @mode = mode
        @skip_bundle_install = skip_bundle_install
      end

      def self.from_argv(argv)
        options = {
          dry_run: false,
          skip_bundle_install: false,
          mode: "patch"
        }

        OptionParser.new do |opts|
          opts.banner = "Usage: bundle-patch [options]"

          opts.on("--dry-run", "Print what would be done, but don't change anything") do
            options[:dry_run] = true
          end

          opts.on("--skip-bundle-install", "Skip running `bundle install` after patching") do
            options[:skip_bundle_install] = true
          end

          opts.on("--mode=MODE", "Update mode: patch (default), minor, or all") do |mode|
            unless %w[patch minor all].include?(mode)
              raise OptionParser::InvalidArgument, "Invalid mode: #{mode}"
            end
            options[:mode] = mode
          end
        end.parse!(argv)

        new(**options)
      end

      def allow_update?(from_version, to_version)
        return true if mode == "all"

        from = Gem::Version.new(from_version)
        to = Gem::Version.new(to_version)

        case mode
        when "patch"
          same_major?(from, to) && same_minor?(from, to)
        when "minor"
          same_major?(from, to)
        else
          true
        end
      end

      private

      def same_major?(v1, v2)
        v1.segments[0] == v2.segments[0]
      end

      def same_minor?(v1, v2)
        v1.segments[1] == v2.segments[1]
      end
    end
  end
end

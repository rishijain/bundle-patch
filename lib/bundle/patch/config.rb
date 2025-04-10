# lib/bundle/patch/config.rb
module Bundle
  module Patch
    class Config
      attr_reader :dry_run, :mode

      def initialize(dry_run: false, mode: "patch")
        @dry_run = dry_run
        @mode = mode
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

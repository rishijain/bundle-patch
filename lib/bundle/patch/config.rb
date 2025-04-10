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
          from.segments[0] == to.segments[0] && from.segments[1] == to.segments[1]
        when "minor"
          from.segments[0] == to.segments[0]
        else
          true
        end
      end
    end
  end
end

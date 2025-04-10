# frozen_string_literal: true

require "rubygems"

module Bundle
  module Patch
    module Audit
      class Advisory
        attr_reader :name, :version, :patched_versions, :raw

        def initialize(raw)
          @raw              = raw
          @name             = raw.dig("gem", "name")
          @version          = Gem::Version.new(raw.dig("gem", "version"))
          @patched_versions = Array(raw.dig("advisory", "patched_versions")).map { Gem::Requirement.new(_1) }
        end

        def patchable?
          latest_patch_version && (latest_patch_version.segments[1] == version.segments[1])
        end

        def latest_patch_version
          @latest_patch_version ||= begin
            candidates = patched_versions.flat_map(&:requirements)
              .map { |op, v| Gem::Version.new(v) if op == ">=" }
              .compact

            candidates
              .select { |v| v.segments[0..1] == version.segments[0..1] } # Same major.minor
              .max
          end
        end
      end
    end
  end
end

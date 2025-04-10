# frozen_string_literal: true

require_relative "patch/version"
require_relative "patch/bundler_audit_installer"
require_relative "patch/audit/parser"
require_relative "patch/gemfile_editor"


module Bundle
  module Patch
    def self.start
      BundlerAuditInstaller.ensure_installed!
      advisories = Audit::Parser.run

      if advisories.empty?
        puts "🎉 No vulnerabilities found!"
        return
      end

      puts "🔒 Found #{advisories.size} vulnerabilities:"
      patchable = []

      advisories.each do |adv|
        data = adv.to_h
        name = data.dig("gem", "name")
        current = data.dig("gem", "version")
        patched_versions = data.dig("advisory", "patched_versions")

        next unless name && current && patched_versions

        current_version = Gem::Version.new(current)

        best_patch = patched_versions
          .map { |req| Gem::Requirement.new(req) rescue nil }
          .compact
          .map { |req| best_version_matching(req) }
          .compact
          .select { |v| same_major?(v, current_version) }
          .min

        if best_patch
          puts "- #{name} (#{current}): #{data.dig("advisory", "title")}"
          puts "  ✅ Patchable → #{best_patch}"
          patchable << { "name" => name, "required_version" => best_patch.to_s }
        else
          puts "- #{name} (#{current}): #{data.dig("advisory", "title")}"
          puts "  ⚠️  Not patchable (requires minor or major update)"
        end
      end



      if patchable.any?
        GemfileEditor.update!(patchable)
      end
    end

    def self.same_major?(v1, v2)
      v1.segments[0] == v2.segments[0]
    end

    def self.best_version_matching(req)
      # This is a dummy "maximum" version used to approximate best patch
      # We'll replace this logic later with a real version fetcher
      # For now, assume upper bound of the requirement if possible
      req.requirements.map { |_, v| v }.compact.min rescue nil
    end
  end
end

# lib/bundle/patch.rb
# frozen_string_literal: true

require_relative "patch/version"
require_relative "patch/bundler_audit_installer"
require_relative "patch/audit/parser"
require_relative "patch/gemfile_editor"
require_relative "patch/gemfile_updater"
require_relative "patch/config"

module Bundle
  module Patch
    def self.start(config = Config.new)
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
        title = data.dig("advisory", "title")

        next unless name && current && patched_versions

        current_version = Gem::Version.new(current)

        candidates = patched_versions
          .map { |req| Gem::Requirement.new(req) rescue nil }
          .compact
          .map { |req| best_version_matching(req) }
          .compact

        allowed = candidates.select { |v| config.allow_update?(current_version, v) }

        if allowed.any?
          best_patch = allowed.min
          puts "- #{name} (#{current}): #{title}"
          puts "  ✅ Patchable → #{best_patch}"
          patchable << { "name" => name, "required_version" => best_patch.to_s }
        else
          puts "- #{name} (#{current}): #{title}"
          puts "  ⚠️  Not patchable in '#{config.mode}' mode"
          if candidates.any?
            puts "     Available patched versions:"
            candidates.each do |v|
              allowed = config.allow_update?(current_version, v)
              reason = allowed ? "✔️ allowed" : "❌ rejected"
              puts "       - #{v} (#{reason})"
            end
          else
            puts "     No valid patched versions found in advisory"
          end
        end
      end

      if patchable.any?
        if config.dry_run
          puts "💡 Skipped Gemfile update and bundle install (dry run)"
        else
          GemfileEditor.update!(patchable)
          GemfileUpdater.update(gemfile_path: "Gemfile", advisories: patchable)
          puts "📦 Running `bundle install`..."
          success = system("bundle install")
          if success
            puts "✅ bundle install completed successfully"
          else
            puts "❌ bundle install failed. Please run it manually."
          end
        end
      end
    end

    def self.best_version_matching(req)
      # Approximate best patch version using upper bound from requirement
      req.requirements.map { |_, v| v }.compact.min rescue nil
    end
  end
end

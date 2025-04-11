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

      advisories.group_by { |adv| adv.to_h.dig("gem", "name") }.each do |name, gem_advisories|
        current = gem_advisories.first.to_h.dig("gem", "version")
        current_version = Gem::Version.new(current)

        # Collect all requirements from advisories
        all_requirements = gem_advisories.flat_map do |adv|
          adv.to_h.dig("advisory", "patched_versions").map do |req|
            Gem::Requirement.new(req) rescue nil
          end
        end.compact

        # Find versions that satisfy all requirements
        candidate_versions = all_requirements
          .map { |req| best_version_matching(req) }
          .compact
          .uniq
          .select { |v| config.allow_update?(current_version, v) }
          .sort

        if candidate_versions.any?
          best_patch = candidate_versions.first
          title_list = gem_advisories.map { |a| a.to_h.dig("advisory", "title") }.uniq
          puts "- #{name} (#{current}):"
          title_list.each { |t| puts "  • #{t}" }
          puts "  ✅ Patchable → #{best_patch}"

          patchable << { "name" => name, "required_version" => best_patch.to_s }
        else
          puts "- #{name} (#{current}):"
          gem_advisories.each do |adv|
            puts "  • #{adv.to_h.dig("advisory", "title")}"
          end
          puts "  ⚠️  Not patchable (no version satisfies all advisories in current mode)"
        end
      end

      if patchable.any?
        if config.dry_run
          puts "💡 Skipped Gemfile update and bundle install (dry run)"
        elsif config.skip_bundle_install
          puts "💡 Skipped bundle install (per --skip-bundle-install)"
          GemfileEditor.update!(patchable)
          GemfileUpdater.update(gemfile_path: "Gemfile", advisories: patchable)
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

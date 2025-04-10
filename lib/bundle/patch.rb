# frozen_string_literal: true

require_relative "patch/version"
require_relative "patch/bundler_audit_installer"
require_relative "patch/audit/parser"

module Bundle
  module Patch
    def self.start
      BundlerAuditInstaller.ensure_installed!
      advisories = Audit::Parser.run

      if advisories.empty?
        puts "🎉 No vulnerabilities found!"
      else
        puts "🔒 Found #{advisories.size} vulnerabilities:"
        advisories.each do |adv|
          gem_name    = adv["gem"]["name"]
          gem_version = adv["gem"]["version"]
          title       = adv["advisory"]["title"]

          puts "- #{gem_name} (#{gem_version}): #{title}"
        end
      end
    end
  end
end

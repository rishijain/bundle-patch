module Bundle
  module Patch
    class BundlerAuditInstaller
      def self.ensure_installed!
        return if system("bundle-audit --version > /dev/null 2>&1")

        puts "🔍 bundler-audit not found. Installing..."
        success = system("gem install bundler-audit")

        unless success
          abort "❌ Failed to install bundler-audit. Please check your RubyGems setup."
        end
      end
    end
  end
end

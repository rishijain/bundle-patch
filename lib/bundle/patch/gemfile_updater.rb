# frozen_string_literal: true

module Bundle
  module Patch
    class GemfileUpdater
      def self.update(gemfile_path:, advisories:)
        contents = File.read(gemfile_path)

        updated = false

        advisories.each do |adv|
          # name = adv.name
          # min_safe_version = adv.min_safe_version

          name = adv["name"]
          min_safe_version = adv["required_version"]

          next unless min_safe_version

          regex = /^(\s*gem\s+["']#{name}["']\s*,\s*)["'][^"']*["'](.*)$/
          contents.gsub!(regex) do
            updated = true
            "#{$1}\"#{min_safe_version}\"#{$2}"
          end
        end

        if updated
          File.write(gemfile_path, contents)
          puts "📝 Updated Gemfile with patched versions"
        else
          puts "✅ No existing Gemfile entries needed updating"
        end
      end
    end
  end
end

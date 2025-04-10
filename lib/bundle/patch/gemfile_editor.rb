# frozen_string_literal: true

module Bundle
  module Patch
    class GemfileEditor
      GEMFILE_PATH = "Gemfile"
      LOCKFILE_PATH = "Gemfile.lock"
      BACKUP_PATH = "Gemfile.bak"

      def self.update!(patchable_gems)
        unless File.exist?(GEMFILE_PATH)
          abort "❌ No Gemfile found in the current directory."
        end

        puts "📝 Backing up Gemfile to #{BACKUP_PATH}..."
        File.write(BACKUP_PATH, File.read(GEMFILE_PATH))

        lines = File.readlines(GEMFILE_PATH)
        updated_lines = lines.dup

        patchable_gems.each do |gem_info|
          name = gem_info["name"]
          version = gem_info["required_version"]

          in_gemfile = gem_declared_in_gemfile?(name, lines)
          in_lockfile = gem_declared_in_lockfile?(name)

          if in_gemfile
            puts "🔧 Updating existing gem: #{name} to '#{version}'"
            updated_lines = update_version_in_lines(updated_lines, name, version)
          elsif in_lockfile
            puts "➕ Gem #{name} is a dependency. Adding it explicitly to Gemfile with version #{version}."
            updated_lines << "gem '#{name}', '#{version}'\n"
          else
            puts "⚠️ Gem #{name} not found in Gemfile or Gemfile.lock. Skipping."
          end
        end

        File.write(GEMFILE_PATH, updated_lines.join)
        puts "✅ Gemfile updated!"
      end

      def self.gem_declared_in_gemfile?(name, lines)
        lines.any? { |line| line =~ /^\s*gem\s+['"]#{name}['"]/ }
      end

      def self.gem_declared_in_lockfile?(name)
        return false unless File.exist?(LOCKFILE_PATH)
        File.read(LOCKFILE_PATH).include?("\n    #{name} ")
      end

      def self.update_version_in_lines(lines, name, version)
        lines.map do |line|
          if line =~ /^\s*gem\s+['"]#{name}['"]/
            parts = line.split(",").map(&:strip)
            gem_name = parts.first
            "#{gem_name}, '#{version}'\n"
          else
            line
          end
        end
      end
    end
  end
end

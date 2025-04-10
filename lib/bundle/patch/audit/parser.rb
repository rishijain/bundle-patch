require "json"
require "open3"
require_relative "advisory"

module Bundle
  module Patch
    module Audit
      class Parser
        def self.run
          puts "🔍 Running `bundle-audit check --format json`..."

          output, _status = Open3.capture2("bundle-audit check --format json")

          # Even if status is non-zero, it's likely due to found vulnerabilities
          begin
            parsed = JSON.parse(output)
            # parsed["results"] || []
            parsed["results"].map { |data| Advisory.new(data) }
          rescue JSON::ParserError => e
            abort "❌ Could not parse bundle-audit output: #{e.message}"
          end
        end
      end
    end
  end
end

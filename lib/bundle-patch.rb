require "optparse"
require "bundle/patch"

# Default options
options = {
  dry_run: false,
  mode: "patch"
}

OptionParser.new do |opts|
  opts.banner = "Usage: bundle-patch [options]"

  opts.on("--dry-run", "Do not modify files or run bundle install") do
    options[:dry_run] = true
  end

  opts.on("--mode=MODE", "Update mode: patch (default), minor, all") do |mode|
    allowed = %w[patch minor all]
    if allowed.include?(mode)
      options[:mode] = mode
    else
      puts "❌ Invalid mode: #{mode}. Must be one of: #{allowed.join(', ')}"
      exit 1
    end
  end
end.parse!

config = Bundle::Patch::Config.new(
  dry_run: options[:dry_run],
  mode: options[:mode]
)

Bundle::Patch.start(config)

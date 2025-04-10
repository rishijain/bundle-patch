require "optparse"
require "bundle/patch"

options = { dry_run: false }

OptionParser.new do |opts|
  opts.on("--dry-run", "Do not modify files or run bundle install") do
    options[:dry_run] = true
  end

  opts.on("--mode=MODE", "Update mode: patch (default), minor, all") do |mode|
    options[:mode] = mode
  end
end.parse!

config = Bundle::Patch::Config.new(
  dry_run: options[:dry_run],
  mode: options[:mode]
)

Bundle::Patch.start(config)

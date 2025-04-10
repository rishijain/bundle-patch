require "optparse"
require "bundle/patch"

options = { dry_run: false }

OptionParser.new do |opts|
  opts.on("--dry-run", "Do not modify files or run bundle install") do
    options[:dry_run] = true
  end
end.parse!

config = Bundle::Patch::Config.new(dry_run: options[:dry_run])
Bundle::Patch.start(config)

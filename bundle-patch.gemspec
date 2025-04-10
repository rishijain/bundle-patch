# frozen_string_literal: true

require_relative "lib/bundle/patch/version"

Gem::Specification.new do |spec|
  spec.name          = "bundle-patch"
  spec.version       = Bundle::Patch::VERSION
  spec.authors       = ["rishijain"]
  spec.email         = ["jainrishi.37@gmail.com"]

  spec.summary       = "Automatically patch vulnerable gems using bundler-audit"
  spec.description   = "bundle-patch is a CLI tool that detects vulnerable gems in your Gemfile and automatically upgrades them to a patchable version based on your configured strategy (patch/minor/all). Uses bundler-audit under the hood."
  spec.homepage      = "https://github.com/rishijain/bundle-patch"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = "https://github.com/rishijain/bundle-patch"
  spec.metadata["changelog_uri"]     = "https://github.com/rishijain/bundle-patch/blob/main/CHANGELOG.md"

  spec.add_runtime_dependency "bundler-audit", "~> 0.9"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end

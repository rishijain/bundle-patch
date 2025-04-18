# frozen_string_literal: true

require "test_helper"
require "stringio"
require_relative "../../lib/bundle/patch/bundler_audit_installer"
require_relative "../../lib/bundle/patch/audit/parser"
require_relative "../../lib/bundle/patch/gemfile_editor"
require_relative "../../lib/bundle/patch/gemfile_updater"

class Bundle::TestPatch < Minitest::Test
  def setup
    @original_stdout = $stdout
    $stdout = StringIO.new
    @config = Bundle::Patch::Config.new
  end

  def teardown
    $stdout = @original_stdout
  end

  def test_that_it_has_a_version_number
    refute_nil ::Bundle::Patch::VERSION
  end

  def test_start_with_no_vulnerabilities
    # Mock BundlerAuditInstaller and Audit::Parser
    Bundle::Patch::BundlerAuditInstaller.stub(:ensure_installed!, nil) do
      Bundle::Patch::Audit::Parser.stub(:run, []) do
        Bundle::Patch.start(@config)
        assert_equal "🎉 No vulnerabilities found!\n", $stdout.string
      end
    end
  end

  def test_start_with_vulnerabilities_dry_run
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 1.0.1"])
    ]
    config = Bundle::Patch::Config.new(dry_run: true)

    Bundle::Patch::BundlerAuditInstaller.stub(:ensure_installed!, nil) do
      Bundle::Patch::Audit::Parser.stub(:run, advisories) do
        Bundle::Patch.start(config)
        output = $stdout.string
        assert_includes output, "🔒 Found 1 vulnerabilities:"
        assert_includes output, "- test-gem (1.0.0):"
        assert_includes output, "✅ Patchable → 1.0.1"
        assert_includes output, "💡 Skipped Gemfile update and bundle install (dry run)"
      end
    end
  end

  def test_start_with_vulnerabilities_skip_bundle_install
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 1.0.1"])
    ]
    config = Bundle::Patch::Config.new(skip_bundle_install: true)

    Bundle::Patch::BundlerAuditInstaller.stub(:ensure_installed!, nil) do
      Bundle::Patch::Audit::Parser.stub(:run, advisories) do
        Bundle::Patch::GemfileEditor.stub(:update!, nil) do
          Bundle::Patch::GemfileUpdater.stub(:update, nil) do
            Bundle::Patch.start(config)
            output = $stdout.string
            assert_includes output, "🔒 Found 1 vulnerabilities:"
            assert_includes output, "💡 Skipped bundle install (per --skip-bundle-install)"
          end
        end
      end
    end
  end

  def test_start_with_vulnerabilities_full_update
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 1.0.1"])
    ]

    Bundle::Patch::BundlerAuditInstaller.stub(:ensure_installed!, nil) do
      Bundle::Patch::Audit::Parser.stub(:run, advisories) do
        Bundle::Patch::GemfileEditor.stub(:update!, nil) do
          Bundle::Patch::GemfileUpdater.stub(:update, nil) do
            Kernel.stub(:system, true) do
              Bundle::Patch.start(@config)
              output = $stdout.string
              assert_includes output, "🔒 Found 1 vulnerabilities:"
              assert_includes output, "📦 Running `bundle install`..."
              assert_includes output, "✅ bundle install completed successfully"
            end
          end
        end
      end
    end
  end

  def test_start_with_multiple_gems
    advisories = [
      mock_advisory("test-gem1", "1.0.0", [">= 1.0.1"]),
      mock_advisory("test-gem2", "2.0.0", [">= 2.0.1"])
    ]

    Bundle::Patch::BundlerAuditInstaller.stub(:ensure_installed!, nil) do
      Bundle::Patch::Audit::Parser.stub(:run, advisories) do
        Bundle::Patch::GemfileEditor.stub(:update!, nil) do
          Bundle::Patch::GemfileUpdater.stub(:update, nil) do
            Kernel.stub(:system, true) do
              Bundle::Patch.start(@config)
              output = $stdout.string
              assert_includes output, "🔒 Found 2 vulnerabilities:"
              assert_includes output, "- test-gem1 (1.0.0):"
              assert_includes output, "- test-gem2 (2.0.0):"
            end
          end
        end
      end
    end
  end

  def test_start_with_unpatchable_gem
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 2.0.0"])
    ]
    config = Bundle::Patch::Config.new(mode: "patch")

    Bundle::Patch::BundlerAuditInstaller.stub(:ensure_installed!, nil) do
      Bundle::Patch::Audit::Parser.stub(:run, advisories) do
        Bundle::Patch.start(config)
        output = $stdout.string
        assert_includes output, "⚠️  Not patchable (no version satisfies all advisories in current mode)"
      end
    end
  end

  private

  def mock_advisory(name, version, patched_versions)
    {
      "type" => "unpatched_gem",
      "gem" => {
        "name" => name,
        "version" => version
      },
      "advisory" => {
        "title" => "Test Advisory",
        "patched_versions" => patched_versions
      }
    }
  end
end

# frozen_string_literal: true

require "test_helper"

class Bundle::TestVersionSelection < Minitest::Test
  def setup
    @config = Bundle::Patch::Config.new
  end

  def test_single_advisory_patch_mode
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 1.0.1"])
    ]
    config = Bundle::Patch::Config.new(mode: "patch")
    
    result = Bundle::Patch.process_gem_advisories("test-gem", advisories, config)
    
    assert_equal "1.0.1", result[:required_version]
  end

  def test_multiple_advisories_patch_mode
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 1.0.1"]),
      mock_advisory("test-gem", "1.0.0", [">= 1.0.2"])
    ]
    config = Bundle::Patch::Config.new(mode: "patch")
    
    result = Bundle::Patch.process_gem_advisories("test-gem", advisories, config)
    
    assert_equal "1.0.2", result[:required_version]
  end

  def test_minor_mode_upgrade
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 1.1.0"]),
      mock_advisory("test-gem", "1.0.0", [">= 1.2.0"])
    ]
    config = Bundle::Patch::Config.new(mode: "minor")
    
    result = Bundle::Patch.process_gem_advisories("test-gem", advisories, config)
    
    assert_equal "1.2.0", result[:required_version]
  end

  def test_all_mode_upgrade
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 2.0.0"]),
      mock_advisory("test-gem", "1.0.0", [">= 2.1.0"])
    ]
    config = Bundle::Patch::Config.new(mode: "all")
    
    result = Bundle::Patch.process_gem_advisories("test-gem", advisories, config)
    
    assert_equal "2.1.0", result[:required_version]
  end

  def test_complex_version_requirements
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 1.0.1", "~> 1.0"]),
      mock_advisory("test-gem", "1.0.0", [">= 1.0.2"])
    ]
    config = Bundle::Patch::Config.new(mode: "patch")
    
    result = Bundle::Patch.process_gem_advisories("test-gem", advisories, config)
    
    assert_equal "1.0.2", result[:required_version]
  end

  def test_rexml_specific_case
    advisories = [
      mock_advisory("rexml", "3.2.6", [">= 3.2.7"]),
      mock_advisory("rexml", "3.2.6", [">= 3.3.2"]),
      mock_advisory("rexml", "3.2.6", [">= 3.3.3"]),
      mock_advisory("rexml", "3.2.6", [">= 3.3.6"]),
      mock_advisory("rexml", "3.2.6", [">= 3.3.9"])
    ]
    config = Bundle::Patch::Config.new(mode: "minor")
    
    result = Bundle::Patch.process_gem_advisories("rexml", advisories, config)
    
    assert_equal "3.3.9", result[:required_version]
  end

  def test_no_patchable_version
    advisories = [
      mock_advisory("test-gem", "1.0.0", [">= 2.0.0"])
    ]
    config = Bundle::Patch::Config.new(mode: "patch")
    
    result = Bundle::Patch.process_gem_advisories("test-gem", advisories, config)
    
    assert_nil result
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
        "patched_versions" => patched_versions
      }
    }
  end
end 
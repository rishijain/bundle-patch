require_relative "bundle/patch"

# Optional: auto-run if this file is executed directly
Bundle::Patch.start if $PROGRAM_NAME == __FILE__

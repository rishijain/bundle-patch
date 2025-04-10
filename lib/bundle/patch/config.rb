# frozen_string_literal: true

module Bundle
  module Patch
    class Config
      attr_reader :dry_run

      def initialize(dry_run: false)
        @dry_run = dry_run
      end
    end
  end
end

require "refer/scans_definitions"
require "refer/scans_references"
require "refer/value/result"

module Refer
  class Runner
    def initialize
    end

    def call(
      files:
      # scan_load_path_for_definitions: false,
      # require_strategies: []
    )
      Value::Result.new(
        definitions: ScansDefinitions.new.call(
          files: files
        ),
        references: ScansReferences.new.call(
          files: files
        ),
      )
    end
  end
end

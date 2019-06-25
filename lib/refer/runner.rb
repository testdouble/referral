require "refer/scans_definitions"
require "refer/scans_references"
require "refer/value/result"

module Refer
  class Runner
    def initialize
    end

    def call(
      file_pattern: "**/*.rb"
      # scan_load_path_for_definitions: false,
      # require_strategies: []
    )
      Value::Result.new(
        definitions: ScansDefinitions.new.call(
          file_pattern: file_pattern
        ),
        references: ScansReferences.new.call(
          file_pattern: file_pattern
        ),
      )
    end
  end
end

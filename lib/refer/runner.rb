module Refer
  class Runner
    def initialize(
      file_pattern: "**/*.rb"
      # scan_load_path_for_definitions: false,
      # require_strategies: []
    )
      @file_pattern = file_pattern
    end

    def call
      Value::Result.new(
        definitions: ScansDefinitions.new.call(
          file_pattern: @file_pattern
        ),
        references: ScansReferences.new.call(
          file_pattern: @file_pattern
        ),
      )
    end
  end
end

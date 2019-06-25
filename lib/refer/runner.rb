require "refer/scans_tokens"
require "refer/value/result"

module Refer
  class Runner
    def call(
      files:
      # scan_load_path_for_definitions: false,
      # require_strategies: []
    )
      Value::Result.new(
        tokens: ScansTokens.new.call(files: files).sort_by { |token|
          [token.file, token.line, token.column]
        }
      )
    end
  end
end

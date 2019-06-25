require "optparse"
require "referral/filters_results"
require "referral/prints_results"

module Referral
  class Cli
    DEFAULT_OPTIONS = {
      delimiter: " ",
      "include-unnamed": false,
    }.freeze

    def initialize(argv)
      @options = parse_argv!(argv)

      @files = argv.empty? ? Dir["**/*.rb"] : argv
    end

    def call
      PrintsResults.new.call(
        FiltersResults.new.call(
          Runner.new.call(files: @files),
          @options
        ),
        @options
      )
    end

    private

    def parse_argv!(argv)
      DEFAULT_OPTIONS.dup.tap do |options|
        op = OptionParser.new
        op.banner += " files"
        version!(op)
        help!(op)
        op.on("-d", "--delimiter [DELIM]", "String separating columns (default: ' ')") do |v|
          "\"#{v}\"".undump
        end
        op.on("-n", "--name [NAME]", "Partial or complete name to filter")
        op.on("--exact-name [NAME]", "Exact fully-qualified name to filter")
        op.on("-p", "--pattern [PATTERN]", Regexp, "Regex pattern to filter")
        op.on("--include-unnamed", TrueClass, "Don't filter unnamed references")
        op.parse!(argv, into: options)
      end
    end

    def version!(op)
      op.on("-v", "--version", "Prints the version") do
        puts VERSION
        exit 0
      end
    end

    def help!(op)
      op.on("-h", "--help", "Prints this help") do
        puts op
        exit 0
      end
    end
  end
end

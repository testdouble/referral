require "optparse"

module Referral
  class ParsesOptions
    DEFAULT_OPTIONS = {
      delimiter: " ",
      "include-unnamed": false,
    }.freeze

    def call(argv)
      DEFAULT_OPTIONS.dup.tap do |options|
        op = OptionParser.new
        op.banner += " files"
        version!(op)
        help!(op)
        op.on("-d", "--delimiter [DELIM]", "String separating columns (default: ' ')") do |v|
          "\"#{v}\"".undump
        end
        op.on("-n", "--name [NAME]", Array, "Partial or complete name to filter (supports,multiple)")
        op.on("--exact-name [NAME]", Array, "Exact name to filter(supports,multiple)")
        op.on("--full-name [NAME]", Array, "Exact, fully-qualified name to filter(supports,multiple)")
        op.on("-p", "--pattern [PATTERN]", Regexp, "Regex pattern to filter")
        op.on("--include-unnamed", TrueClass, "Include reference without identifiers (default: false)")
        op.parse!(argv, into: options)
      end
    end

    private

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

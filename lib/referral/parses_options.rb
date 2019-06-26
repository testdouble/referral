require "optparse"

module Referral
  class ParsesOptions
    DEFAULT_OPTIONS = {
      columns: ["location", "type", "full_name"],
      delimiter: " ",
      "include-unnamed": false,
      sort: "file",
      "print-headers": false,
    }.freeze

    def call(argv)
      DEFAULT_OPTIONS.dup.tap do |options|
        op = OptionParser.new
        op.banner += " files"
        version!(op)
        help!(op)
        op.on("-n", "--name [NAME]", Array, "Partial or complete name to filter")
        op.on("--exact-name [NAME]", Array, "Exact name to filter")
        op.on("--full-name [NAME]", Array, "Exact, fully-qualified name to filter")
        op.on("-p", "--pattern [PATTERN]", Regexp, "Regex pattern to filter")
        op.on("-c", "--columns [COL1,COL2,COL3]", Array, "Columns to print (default: location,type,full_name)")
        op.on("-s", "--sort [NAME]", "Sort order (default: file)")
        op.on("-d", "--delimiter [DELIM]", "String separating columns (default: ' ')") do |v|
          "\"#{v}\"".undump
        end
        op.on("--print-headers", TrueClass, "Print header names (default: false)")
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

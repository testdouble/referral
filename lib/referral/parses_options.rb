require "optparse"
require "referral/value/options"

module Referral
  class ParsesOptions
    def call(argv)
      options = snake_case(run_optparse(argv))
      Value::Options.default.merge(
        merge_files(options, argv)
      ).freeze
    end

    private

    def run_optparse(argv)
      {}.tap do |options|
        op = OptionParser.new
        op.banner += " files"
        op.version = Referral::VERSION
        version!(op)
        help!(op)
        op.on("-n", "--name [NAME]", Array, "Partial or complete name(s) to filter")
        op.on("--exact-name [NAME]", Array, "Exact name(s) to filter")
        op.on("--full-name [NAME]", Array, "Exact, fully-qualified name(s) to filter")
        op.on("-p", "--pattern [PATTERN]", Regexp, "Regex pattern to filter")
        op.on("--include-unnamed", TrueClass, "Include reference without identifiers (default: false)")
        op.on("-s", "--sort [NAME]", "Sort order (default: file). See Referral::SORT_FUNCTIONS")
        op.on("--print-headers", TrueClass, "Print header names (default: false)")
        op.on("-c", "--columns [COL1,COL2,COL3]", Array, "Columns & order (default: location,type,full_name). See Referral::COLUMN_FUNCTIONS")
        op.on("-d", "--delimiter [DELIM]", "String separating columns (default: ' ')") do |v|
          "\"#{v}\"".undump
        end
        op.parse!(argv, into: options)
      end
    end

    def snake_case(options)
      options.transform_keys { |k|
        k.to_s.tr("-", "_").to_sym
      }
    end

    def merge_files(options, argv)
      options.merge(
        files: argv.empty? ? Dir["**/*.rb"] : argv.dup
      )
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

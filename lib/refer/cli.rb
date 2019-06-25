require "optparse"

module Refer
  class Cli
    DEFAULT_OPTIONS = {
      delimiter: " ",
    }.freeze

    def initialize(argv)
      parse_argv!(argv, @options = DEFAULT_OPTIONS.dup)

      @files = argv.empty? ? Dir["**/*.rb"] : argv
    end

    def call
      result = Runner.new.call(
        files: @files
      )

      result.tokens.each do |t|
        next if t.hidden?
        line_components = [
          "#{t.file}:#{t.line}:#{t.column}:",
          t.full_name.to_s,
          "(#{t.type_name})",
        ]
        puts line_components.join(@options[:delimiter])
      end

      0
    end

    private

    def parse_argv!(argv, into)
      op = OptionParser.new
      op.banner += " files"
      version!(op)
      help!(op)
      op.on("-d", "--delimiter [DELIM]", "String separating each column (default ' ')")
      op.on("-n", "--name [NAME]", "Name or regex pattern ")
      op.parse!(argv, into: into)
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

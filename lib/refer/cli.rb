module Refer
  class Cli
    def initialize(argv)
      @file_pattern = argv[0] || "**/*.rb"
    end

    def call
      result = Runner.new.call(
        file_pattern: @file_pattern
      )

      (result.definitions + result.references).each do |d|
        puts "#{d.file}:#{d.line}:#{d.column}: #{d.full_name} (#{d.type_name})"
      end

      0
    end
  end
end

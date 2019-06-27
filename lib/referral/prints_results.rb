require "referral/file_store"

module Referral
  COLUMN_FUNCTIONS = {
    id: ->(token) {
      token.id
    },
    location: ->(token) {
      "#{token.file}:#{token.line}:#{token.column}:"
    },
    file: ->(token) {
      token.file
    },
    line: ->(token) {
      token.line
    },
    column: ->(token) {
      token.column
    },
    type: ->(token) {
      token.type_name
    },
    scope: ->(token) {
      token.scope
    },
    name: ->(token) {
      token.literal_name
    },
    full_name: ->(token) {
      token.full_name
    },
    source: ->(token) {
      FileStore.read_line(token.file, token.line)
    },
  }

  class PrintsResults
    def call(result, options)
      if options[:print_headers]
        puts options[:columns].join(options[:delimiter])
      end

      result.tokens.each do |token|
        cells = options[:columns].map { |column_name|
          if (column = COLUMN_FUNCTIONS[column_name.to_sym])
            column.call(token)
          else
            raise Referral::Error.new("Column '#{column_name}' not found in Referral::COLUMN_FUNCTIONS")
          end
        }
        puts cells.join(options[:delimiter])
      end
    end
  end
end

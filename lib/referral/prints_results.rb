module Referral
  COLUMN_FUNCTIONS = {
    location: ->(token) {
      "#{token.file}:#{token.line}:#{token.column}:"
    },
    id: ->(token) {
      token.id
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
            raise "Column '#{column_name}' not found in Referral::COLUMN_FUNCTIONS"
          end
        }
        puts cells.join(options[:delimiter])
      end
    end
  end
end

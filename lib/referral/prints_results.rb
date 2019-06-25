module Referral
  COLUMNS = {
    location: ->(token) {
      "#{token.file}:#{token.line}:#{token.column}:"
    },
    type: ->(token) {
      token.type_name.to_s
    },
    name: ->(token) {
      token.name.to_s
    },
    full_name: ->(token) {
      token.full_name.to_s
    },
  }

  class PrintsResults
    def call(result, options)
      if options[:"print-headers"]
        puts options[:columns].join(options[:delimiter])
      end

      result.tokens.each do |token|
        next if token.hidden?
        cells = options[:columns].map { |column_name|
          if (column = COLUMNS[column_name.to_sym])
            column.call(token)
          else
            raise "Column '#{column_name}' not found in Referral::COLUMNS"
          end
        }
        puts cells.join(options[:delimiter])
      end
    end
  end
end

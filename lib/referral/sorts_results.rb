module Referral
  SORT_FUNCTIONS = {
    file: ->(token) {
      [token.file, token.line, token.column, token.id]
    },
  }
  class SortsResults
    def call(result, options)
      if (sort_func = SORT_FUNCTIONS[options[:sort].to_sym])

        Value::Result.new(result.to_h.merge(
          tokens: result.tokens.sort_by { |token|
            sort_func.call(token)
          }
        ))
      else
        raise "Sort '#{options[:sort]} not found in Referral::SORT_FUNCTIONS"
      end
    end
  end
end

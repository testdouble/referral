module Referral
  SORT_FUNCTIONS = {
    file: ->(token) {
      [token.file, token.line, token.column, token.id]
    },
  }
  class SortsTokens
    def call(tokens, options)
      if (sort_func = SORT_FUNCTIONS[options[:sort].to_sym])
        tokens.sort_by { |token|
          sort_func.call(token)
        }
      else
        raise "Sort '#{options[:sort]} not found in Referral::SORT_FUNCTIONS"
      end
    end
  end
end

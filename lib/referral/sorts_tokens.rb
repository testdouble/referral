module Referral
  SORT_FUNCTIONS = {
    file: ->(tokens) {
      tokens.sort_by { |token|
        [token.file, token.line, token.column, token.id]
      }
    },
    scope: ->(tokens) {
      max_length = tokens.map { |t| t.fully_qualified.size }.max
      tokens.sort_by { |token|
        names = token.fully_qualified.map { |fq| fq.name.to_s }
        [
          *names.fill("", names.size...max_length),
          token.file,
          token.line,
          token.column,
          token.id,
        ]
      }
    },
  }
  class SortsTokens
    def call(tokens, options)
      if (sort_func = SORT_FUNCTIONS[options[:sort].to_sym])
        sort_func.call(tokens)
      else
        raise "Sort '#{options[:sort]} not found in Referral::SORT_FUNCTIONS"
      end
    end
  end
end
require "referral/matches_token_names"
require "referral/value/result"

module Referral
  FILTER_FUNCTIONS = {
    name: ->(token, names) {
      names.any? { |name| token.full_name.include?(name) }
    },
    exact_name: ->(token, exact_names) {
      exact_names.any? { |query|
        MatchesTokenNames.subset(token, query)
      }
    },
    full_name: ->(token, exact_names) {
      exact_names.any? { |query|
        MatchesTokenNames.entirely(token, query)
      }
    },
    pattern: ->(token, opt_val) {
      opt_val.match(token.full_name)
    },
    include_unnamed: ->(token, opt_val) {
      if !opt_val
        /\w/ =~ token.full_name
      else
        true
      end
    },
  }
  class FiltersResults
    def call(result, options)
      filters = options.select { |(opt_name, _)|
        FILTER_FUNCTIONS.key?(opt_name)
      }

      if !filters.empty?
        Value::Result.new(result.to_h.merge(
          tokens: result.tokens.filter { |token|
            filters.all? { |(opt_name, opt_val)|
              FILTER_FUNCTIONS[opt_name].call(token, opt_val)
            }
          }
        ))
      else
        result
      end
    end
  end
end

require "referral/matches_token_names"
require "referral/value/result"
require "referral/file_store"

module Referral
  FILTER_FUNCTIONS = {
    name: ->(token, names) {
      names.any? { |name| token.full_name.include?(name) }
    },
    exact_name: ->(token, exact_names) {
      exact_names.any? { |query|
        MatchesTokenNames.subset(token.full_name_tokens, query)
      }
    },
    full_name: ->(token, full_names) {
      full_names.any? { |query|
        MatchesTokenNames.entirely(token.full_name_tokens, query)
      }
    },
    scope: ->(token, scope_names) {
      scope_names.any? { |query|
        MatchesTokenNames.subset(token.scope_tokens, query)
      }
    },
    pattern: ->(token, regex) {
      regex.match(token.full_name) || regex.match(FileStore.read_line(token.file, token.line))
    },
    type: ->(token, types) {
      types.include?(token.node_type.name.to_s)
    },
    include_unnamed: ->(token, opt_val) {
      if !opt_val
        /\w/ =~ token.full_name
      else
        true
      end
    },
  }
  class FiltersTokens
    def call(tokens, options)
      filters = options.to_h.select { |opt_name, opt_val|
        FILTER_FUNCTIONS.key?(opt_name) && !opt_val.nil?
      }

      if !filters.empty?
        tokens.filter { |token|
          filters.all? { |(opt_name, opt_val)|
            FILTER_FUNCTIONS[opt_name].call(token, opt_val)
          }
        }
      else
        result
      end
    end
  end
end

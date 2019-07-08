module Referral
  class MatchesTokenNames
    def self.subset(tokens, query)
      token_tokens = names_from_tokens(tokens)
      query_tokens = names_from_query(query)

      token_tokens & query_tokens == query_tokens
    end

    def self.entirely(tokens, query)
      names_from_tokens(tokens) == names_from_query(query)
    end

    def self.names_from_tokens(tokens)
      tokens.reject { |t| t.name.nil? }.map { |t| t.name.to_s }
    end

    def self.names_from_query(query)
      query.split(Regexp.union(JOIN_SEPARATORS.values))
    end
  end
end

module Referral
  class MatchesTokenNames
    def self.subset(token, query)
      token_tokens = names_from_token(token)
      query_tokens = names_from_query(query)

      token_tokens & query_tokens == query_tokens
    end

    def self.entirely(token, query)
      names_from_token(token) == names_from_query(query)
    end

    def self.names_from_token(token)
      token.full_name_tokens.reject { |t| t.name.nil? }.map { |t| t.name.to_s }
    end

    def self.names_from_query(query)
      query.split(Regexp.union(JOIN_SEPARATORS.values))
    end
  end
end

require "referral/filters_tokens"
require "referral/sorts_tokens"
require "referral/scans_tokens"
require "referral/value/result"

module Referral
  class Runner
    def call(options)
      Value::Result.new(
        tokens: SortsTokens.new.call(
          FiltersTokens.new.call(
            ScansTokens.new.call(files: options.files),
            options
          ),
          options
        )
      )
    end
  end
end

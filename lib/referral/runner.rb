require "referral/scans_tokens"
require "referral/value/result"

module Referral
  class Runner
    def call(files:)
      Value::Result.new(
        tokens: ScansTokens.new.call(files: files)
      )
    end
  end
end

require "referral/version"
require "referral/error"

module Referral
  def self.run(*args, **kwargs, &blk)
    require "referral/ensures_working_ruby"
    Referral::EnsuresWorkingRuby.new.call

    require "referral/runner"
    Runner.new.call(*args, **kwargs, &blk)
  end
end

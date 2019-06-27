require "referral/runner"

require "referral/version"
require "referral/error"
require "referral/cli"

module Referral
  def self.run(*args, **kwargs, &blk)
    Runner.new.call(*args, **kwargs, &blk)
  end
end

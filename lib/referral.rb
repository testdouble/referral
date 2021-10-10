require "referral/version"
require "referral/error"

module Referral
  def self.run(...)
    require "referral/ensures_working_ruby"
    Referral::EnsuresWorkingRuby.new.call

    require "referral/runner"
    Runner.new.call(...)
  end
end

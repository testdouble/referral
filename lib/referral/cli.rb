require "referral/parses_options"
require "referral/prints_results"

module Referral
  class Cli
    def initialize(argv)
      @options = ParsesOptions.new.call(argv)
    end

    def call
      PrintsResults.new.call(Runner.new.call(@options), @options)
    end
  end
end

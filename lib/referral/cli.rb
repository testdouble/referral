require "referral/parses_options"
require "referral/filters_results"
require "referral/prints_results"

module Referral
  class Cli
    def initialize(argv)
      @options = ParsesOptions.new.call(argv)
      @files = argv.empty? ? Dir["**/*.rb"] : argv
    end

    def call
      PrintsResults.new.call(
        FiltersResults.new.call(
          Runner.new.call(files: @files),
          @options
        ),
        @options
      )
    end
  end
end

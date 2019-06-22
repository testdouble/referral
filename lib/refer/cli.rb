module Refer
  class Cli
    def initialize(argv)
      @pattern = argv[0] || "**/*.rb"
    end

    def run
      Refer.run(@pattern)
    end
  end
end

require "refer/runner"

require "refer/version"
require "refer/cli"

module Refer
  def self.run(*args, **kwargs, &blk)
    Runner.new.call(*args, **kwargs, &blk)
  end
end

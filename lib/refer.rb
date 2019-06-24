require "refer/value/node_type"
require "refer/value/definition"
require "refer/value/reference"
require "refer/value/result"

require "refer/scans_definitions"
require "refer/scans_references"
require "refer/runner"

require "refer/version"
require "refer/cli"

module Refer
  def self.run(*args, **kwargs, &blk)
    Runner.new.call(*args, **kwargs, &blk)
  end
end

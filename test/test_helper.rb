$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "refer"

require "minitest/autorun"

class ReferTest < Minitest::Test
  def pry!(b)
    require "pry"
    b.pry
  end
end

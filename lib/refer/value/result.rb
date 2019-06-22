module Refer
  module Value
    class Result < Struct.new(:definitions, :references, keyword_init: true)
    end
  end
end

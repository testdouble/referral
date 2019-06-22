module Refer
  module Value
    class NodeType < Struct.new(:name, :ast_type, keyword_init: true)
    end
  end
end

module Refer
  module Value
    class NodeType < Struct.new(
      :name,
      :ast_type,
      :join_separator,
      :name_finder,
      :token_type,
      keyword_init: true
    )
    end
  end
end

module Referral
  module Value
    class NodeType < Struct.new(
      :name,
      :ast_type,
      :join_separator,
      :name_finder,
      :token_type,
      :reverse_identifiers,
      :good_parent,
      :arity_finder,
      keyword_init: true
    )
    end
  end
end

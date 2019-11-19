require "referral/token_types"
require "referral/value/token"

module Referral
  class TranslatesNodeToToken
    def call(node, parent, file)
      return unless (type = TOKEN_TYPES.values.find { |d| node.type == d.ast_type })

      Value::Token.new(
        name: type.name_finder.call(node),
        node_type: type,
        parent: parent,
        file: file,
        line: node.first_lineno,
        column: node.first_column,
        arity: type&.arity_finder&.call(node)
      )
    end
  end
end

require "referral/token_types"
require "referral/value/token"

module Referral
  class TranslatesNodeToToken
    def call(node, parent, file)
      return unless (type = TOKEN_TYPES.values.find { |d| node.type == d.ast_type })

      Value::Token.new(
        name: type.name_finder.call(node),
        node_type: type,
        parent: parent_unless_bad_parent(parent, type),
        file: file,
        line: node.first_lineno,
        column: node.first_column
      )
    end

    private

    def parent_unless_bad_parent(parent_token, type)
      return parent_token if parent_token&.node_type&.good_parent

      # puts "should a #{parent_token.node_type.name} parent a #{type.name}?"
      # return if parent_token.node_type.name == :local_var_assign
      # parent_token
    end
  end
end

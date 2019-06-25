require "refer/token_types"
require "refer/value/token"

module Refer
  class TranslatesNodeToToken
    def self.definition(node, parent, file)
      new.call(node, parent, file, :definition)
    end

    def self.reference(node, parent, file)
      new.call(node, parent, file, :reference)
    end

    def call(node, parent, file, token_type)
      return unless (type = TOKEN_TYPES.values.find { |d|
                       d.token_type == token_type && node.type == d.ast_type
                     })

      Value::Token.new(
        name: type.name_finder.call(node),
        node_type: type,
        parent: parent,
        file: file,
        line: node.first_lineno,
        column: node.first_column
      )
    end
  end
end

module Refer
  class TranslatesTokenToNode
    def self.definition(node, parent, file)
      new.call(node, parent, file, Value::Definition, Value::Definition::TYPES)
    end

    def self.reference(node, parent, file)
      new.call(node, parent, file, Value::Reference, Value::Reference::TYPES)
    end

    def call(node, parent, file, token_type, node_types)
      return unless (type = node_types.values.find { |d| node.type == d.ast_type })

      token_type.new(
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

require_relative "token"

module Refer
  module Value
    class Reference < Token
      def self.from_ast_node(node, parent, file)
        return unless (type = TYPES.values.find { |d| node.type == d.ast_type })

        name = if [:CALL, :COLON2].include?(node.type)
          node.children[1]
        elsif node.type == :CONST
          node.children[0]
        end

        new(
          name: name,
          node_type: type,
          parent: parent,
          file: file,
          line: node.first_lineno,
          column: node.first_column
        )
      end

      TYPES = {
        call: NodeType.new(name: :call, ast_type: :CALL),
        constant: NodeType.new(name: :constant, ast_type: :CONST),
        double_colon: NodeType.new(name: :double_colon, ast_type: :COLON2),
      }

      def definition?
        false
      end

      def joiner_syntax
        if node_type === TYPES[:call]
          "."
        else
          "::"
        end
      end
    end
  end
end

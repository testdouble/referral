module Refer
  module Value
    class Reference < Struct.new(
      :name, :node_type, :parent, :file, :line, :column, keyword_init: true
    )

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
    end
  end
end

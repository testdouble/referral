module Refer
  module Value
    class Definition < Struct.new(
      :name, :node_type, :parent, :file, :line, :column, keyword_init: true
    )

      def self.from_ast_node(node, parent, file)
        return unless (type = TYPES.values.find { |d| node.type == d.ast_type })

        name = if [:CLASS, :MODULE].include?(node.type)
          node.children[0].children[1]
        elsif [:CDECL, :DEFN].include?(node.type)
          node.children[0]
        elsif node.type == :DEFS
          node.children[1]
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
        module: NodeType.new(name: :module, ast_type: :MODULE),
        class: NodeType.new(name: :class, ast_type: :CLASS),
        constant: NodeType.new(name: :constant, ast_type: :CDECL),
        static_method: NodeType.new(name: :static_method, ast_type: :DEFS),
        instance_method: NodeType.new(name: :instance_method, ast_type: :DEFN),
      }
    end
  end
end

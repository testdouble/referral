require_relative "token"

module Refer
  module Value
    class Definition < Token
      TYPES = {
        module: NodeType.new(name: :module, ast_type: :MODULE, join_separator: "::",
                             name_finder: ->(node) { node.children[0].children[1] }),
        class: NodeType.new(name: :class, ast_type: :CLASS, join_separator: "::",
                            name_finder: ->(node) { node.children[0].children[1] }),
        constant: NodeType.new(name: :constant, ast_type: :CDECL, join_separator: "::",
                               name_finder: ->(node) { node.children[0] }),
        class_method: NodeType.new(name: :class_method, ast_type: :DEFS, join_separator: ".",
                                   name_finder: ->(node) { node.children[1] }),
        instance_method: NodeType.new(name: :instance_method, ast_type: :DEFN, join_separator: "#",
                                      name_finder: ->(node) { node.children[0] }),
      }

      def definition?
        true
      end
    end
  end
end

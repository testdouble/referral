require "refer/value/token"
require "refer/translates_node_to_token"

module Refer
  module Value
    class Reference < Token
      TYPES = {
        call: NodeType.new(name: :call, ast_type: :CALL, join_separator: ".",
                           name_finder: ->(node) { node.children[1] }),
        constant: NodeType.new(name: :constant, ast_type: :CONST, join_separator: "::",
                               name_finder: ->(node) { node.children[0] }),
        double_colon: NodeType.new(name: :double_colon, ast_type: :COLON2, join_separator: "::",
                                   name_finder: ->(node) { node.children[1] }),
      }

      def definition?
        false
      end
    end
  end
end

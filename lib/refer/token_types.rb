require "refer/value/node_type"

module Refer
  TOKEN_TYPES = {
    module: Value::NodeType.new(
      name: :module,
      ast_type: :MODULE,
      join_separator: "::",
      token_type: :definition,
      name_finder: ->(node) { node.children[0].children[1] }
    ),
    class: Value::NodeType.new(
      name: :class,
      ast_type: :CLASS,
      join_separator: "::",
      token_type: :definition,
      name_finder: ->(node) { node.children[0].children[1] }
    ),
    constant_def: Value::NodeType.new(
      name: :constant_declaration,
      ast_type: :CDECL,
      join_separator: "::",
      token_type: :definition,
      name_finder: ->(node) { node.children[0] }
    ),
    class_method: Value::NodeType.new(
      name: :class_method,
      ast_type: :DEFS,
      join_separator: ".",
      token_type: :definition,
      name_finder: ->(node) { node.children[1] }
    ),
    instance_method: Value::NodeType.new(
      name: :instance_method,
      ast_type: :DEFN,
      join_separator: "#",
      token_type: :definition,
      name_finder: ->(node) { node.children[0] }
    ),
    call: Value::NodeType.new(
      name: :call,
      ast_type: :CALL,
      join_separator: ".",
      token_type: :reference,
      name_finder: ->(node) { node.children[1] }
    ),
    constant_ref: Value::NodeType.new(
      name: :constant,
      ast_type: :CONST,
      join_separator: "::",
      token_type: :reference,
      name_finder: ->(node) { node.children[0] }
    ),
    double_colon: Value::NodeType.new(
      name: :constant,
      ast_type: :COLON2,
      join_separator: "::",
      token_type: :reference,
      name_finder: ->(node) { node.children[1] }
    ),
  }
end

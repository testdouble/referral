require "referral/value/node_type"

module Referral
  JOIN_SEPARATORS = {
    double_colon: "::",
    dot: ".",
    hash: "#",
    tilde: "~",
  }
  TOKEN_TYPES = {
    module: Value::NodeType.new(
      name: :module,
      ast_type: :MODULE,
      join_separator: JOIN_SEPARATORS[:double_colon],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: true,
      name_finder: ->(node) { nil }
    ),
    class: Value::NodeType.new(
      name: :class,
      ast_type: :CLASS,
      join_separator: JOIN_SEPARATORS[:double_colon],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: true,
      name_finder: ->(node) { nil }
    ),
    constant_def: Value::NodeType.new(
      name: :constant_declaration,
      ast_type: :CDECL,
      join_separator: JOIN_SEPARATORS[:double_colon],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: true,
      name_finder: ->(node) {
        possible_name = node.children[0]
        possible_name.is_a?(Symbol) ? possible_name : nil
      }
    ),
    class_method: Value::NodeType.new(
      name: :class_method,
      ast_type: :DEFS,
      join_separator: JOIN_SEPARATORS[:dot],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: true,
      name_finder: ->(node) { node.children[1] }
    ),
    instance_method: Value::NodeType.new(
      name: :instance_method,
      ast_type: :DEFN,
      join_separator: JOIN_SEPARATORS[:hash],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: true,
      name_finder: ->(node) { node.children[0] }
    ),
    local_var_assign: Value::NodeType.new(
      name: :local_var_assign,
      ast_type: :LASGN,
      join_separator: JOIN_SEPARATORS[:tilde],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    instance_var_assign: Value::NodeType.new(
      name: :instance_var_assign,
      ast_type: :IASGN,
      join_separator: JOIN_SEPARATORS[:tilde],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    class_var_assign: Value::NodeType.new(
      name: :class_var_assign,
      ast_type: :CVASGN,
      join_separator: JOIN_SEPARATORS[:tilde],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    global_var_assign: Value::NodeType.new(
      name: :global_var_assign,
      ast_type: :GASGN,
      join_separator: JOIN_SEPARATORS[:tilde],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    attr_assign: Value::NodeType.new(
      name: :attr_assign,
      ast_type: :ATTRASGN,
      join_separator: JOIN_SEPARATORS[:dot],
      token_type: :definition,
      reverse_identifiers: false,
      good_parent: false,
      name_finder: ->(node) { node.children[1] }
    ),
    call: Value::NodeType.new(
      name: :call,
      ast_type: :CALL,
      join_separator: JOIN_SEPARATORS[:dot],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: true,
      name_finder: ->(node) { node.children[1] }
    ),
    function_call: Value::NodeType.new(
      name: :function_call,
      ast_type: :FCALL,
      join_separator: JOIN_SEPARATORS[:dot],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    local_var: Value::NodeType.new(
      name: :local_var,
      ast_type: :LVAR,
      join_separator: JOIN_SEPARATORS[:tilde],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    instance_var: Value::NodeType.new(
      name: :instance_var,
      ast_type: :IVAR,
      join_separator: JOIN_SEPARATORS[:tilde],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    class_var: Value::NodeType.new(
      name: :class_var,
      ast_type: :CVAR,
      join_separator: JOIN_SEPARATORS[:tilde],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    global_var: Value::NodeType.new(
      name: :global_var,
      ast_type: :GVAR,
      join_separator: JOIN_SEPARATORS[:tilde],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    constant_ref: Value::NodeType.new(
      name: :constant,
      ast_type: :CONST,
      join_separator: JOIN_SEPARATORS[:double_colon],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
    double_colon: Value::NodeType.new(
      name: :constant,
      ast_type: :COLON2,
      join_separator: JOIN_SEPARATORS[:double_colon],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: false,
      name_finder: ->(node) { node.children[1] }
    ),
    triple_colon: Value::NodeType.new(
      name: :constant,
      ast_type: :COLON3,
      join_separator: JOIN_SEPARATORS[:double_colon],
      token_type: :reference,
      reverse_identifiers: true,
      good_parent: false,
      name_finder: ->(node) { node.children[0] }
    ),
  }
end

require "refer/value/reference"

module Refer
  class BuildsIdentTokens
    def call(root_node, root_token)
      find_names(root_node, root_token).tap do |identifiers|
        root_token.identifiers = identifiers # eww gross mutation
      end
    end

    private

    def find_names(node, parent)
      return [] unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)

      [
        *find_names(node.children[0], parent),
        Value::Reference.from_ast_node(node, parent, parent.file),
      ].compact
    end
  end
end

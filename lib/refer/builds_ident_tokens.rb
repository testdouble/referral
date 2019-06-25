require "refer/translates_node_to_token"

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
        TranslatesNodeToToken.reference(node, parent, parent.file),
      ].compact
    end
  end
end

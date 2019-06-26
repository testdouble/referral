require "referral/translates_node_to_token"

module Referral
  class TokenizesIdentifiers
    def initialize
      @translates_node_to_token = TranslatesNodeToToken.new
    end

    def call(root_node, root_token)
      find_names(root_node, root_token).tap do |identifiers|
        root_token.identifiers = if root_token.node_type.reverse_identifiers
          # TODO WAT.
          identifiers # .reverse
        else
          identifiers
        end

        if identifiers.any? { |id| id.node_type == TOKEN_TYPES[:triple_colon] }
          root_token.parent = nil
        end
      end
    end

    private

    def find_names(node, parent)
      return [] unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)

      [
        *find_names(node.children.first, parent),
        @translates_node_to_token.call(node, parent, parent.file),
      ].compact
    end
  end
end

require "refer/translates_node_to_token"
require "refer/tokenizes_identifiers"

module Refer
  class ScansTokens
    def initialize
      @tokenizes_identifiers = TokenizesIdentifiers.new
    end

    def call(files:, &blk)
      files.flat_map do |file|
        root = RubyVM::AbstractSyntaxTree.parse_file(file)
        find_tokens([root], nil, file)
      end
    end

    private

    def find_tokens(nodes, parent, file)
      nodes.flat_map { |node|
        next unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)

        if (definition = TranslatesNodeToToken.definition(node, parent, file))
          @tokenizes_identifiers.call(node, definition)
          [definition, *find_tokens(node.children, definition, file)]
        else
          children = find_tokens(node.children, parent, file)

          if (reference = TranslatesNodeToToken.reference(node, children.first, file))
            [reference, *children]
          else
            children
          end
        end
      }.compact
    end
  end
end

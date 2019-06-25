require "refer/translates_node_to_token"

module Refer
  class ScansReferences
    def call(files:, &blk)
      files.flat_map { |file|
        root = RubyVM::AbstractSyntaxTree.parse_file(file)
        find_tokens([root], file)
      }
    end

    private

    def find_tokens(nodes, file)
      nodes.flat_map { |node|
        next unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)

        children = find_tokens(node.children, file)
        [
          TranslatesNodeToToken.reference(node, children.first, file),
          *children,
        ]
      }.compact
    end
  end
end

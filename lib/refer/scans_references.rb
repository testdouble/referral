module Refer
  class ScansReferences
    def call(file_pattern:, &blk)
      Dir[file_pattern].flat_map { |file|
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
          TranslatesTokenToNode.reference(node, children.first, file),
          *children,
        ]
      }.compact
    end
  end
end

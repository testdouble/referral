module Refer
  class ScansDefinitions
    def call(file_pattern:, &blk)
      Dir[file_pattern].flat_map { |file|
        root = RubyVM::AbstractSyntaxTree.parse_file(file)
        find_tokens([root], nil, file)
      }
    end

    private

    def find_tokens(nodes, parent, file)
      nodes.flat_map { |node|
        next unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)

        if (definition = TranslatesTokenToNode.definition(node, parent, file))
          [definition, *find_tokens(node.children, definition, file)]
        else
          find_tokens(node.children, parent, file)
        end
      }.compact
    end
  end
end

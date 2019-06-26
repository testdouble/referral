require "referral/translates_node_to_token"
require "referral/expands_directories"
require "referral/tokenizes_identifiers"

module Referral
  class ScansTokens
    def initialize
      @expands_directories = ExpandsDirectories.new
      @tokenizes_identifiers = TokenizesIdentifiers.new
    end

    def call(files:, &blk)
      @expands_directories.call(files).flat_map { |file|
        begin
          root = RubyVM::AbstractSyntaxTree.parse_file(file)
          find_tokens([root], nil, file)
        rescue SyntaxError => e
          warn "ERROR: Failed to parse \"#{file}\": #{e.message} (#{e.class})"
        rescue SystemCallError => e
          warn "ERROR: Failed to read \"#{file}\": #{e.message} (#{e.class})"
        end
      }.compact
    end

    private

    def find_tokens(nodes, parent, file)
      nodes.flat_map { |node|
        next unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)

        if (definition = TranslatesNodeToToken.definition(node, parent, file))
          @tokenizes_identifiers.call(node, definition)
          [definition, *find_tokens(node.children[1..-1], definition, file)]
        else
          children = find_tokens(node.children, parent, file)
          if (reference = TranslatesNodeToToken.reference(node, children.first, file))
            children.each(&:hide!)
            [reference, *children]
          else
            children
          end
        end
      }.compact
    end
  end
end

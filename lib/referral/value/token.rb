require "digest/sha1"

module Referral
  module Value
    class Token < Struct.new(
      :name, :identifiers, :node_type, :parent, :file, :line, :column, :arity,
      keyword_init: true
    )

      def scope_and_names
        [
          *parent&.scope_and_names,
          *literal_name_tokens
        ].compact
      end

      def scope
        join_names(scope_tokens)
      end

      def scope_tokens
        return [] if parent.nil?

        ancestors.take_while { |t| t.node_type.good_parent }.flat_map(&:literal_name_tokens)
      end

      def ancestors
        return [] if parent.nil?
        [*parent.ancestors, parent]
      end

      def full_name
        join_names(full_name_tokens)
      end

      def full_name_tokens
        [
          *(include_parents_in_full_name? ? parent&.scope_and_names : []),
          *literal_name_tokens
        ].compact
      end

      def literal_name
        join_names(literal_name_tokens)
      end

      def literal_name_tokens
        if identifiers && !identifiers.empty?
          identifiers
        else
          [self]
        end
      end

      def type_name
        node_type.name.to_s
      end

      def id
        Digest::SHA1.hexdigest(to_h.merge(
          parent: nil,
          identifiers: identifiers&.map(&:id),
          node_type: node_type.name
        ).inspect)[0..6]
      end

      protected

      def include_parents_in_full_name?
        node_type.token_type == :definition && node_type.good_parent == true
      end

      def join_names(tokens)
        tokens.reduce("") { |s, token|
          next s unless token.name
          if s.empty?
            token.name.to_s
          else
            "#{s}#{token.node_type.join_separator}#{token.name}"
          end
        }
      end
    end
  end
end

require "digest/sha1"

module Referral
  module Value
    class Token < Struct.new(
      :name, :identifiers, :node_type, :parent, :file, :line, :column, :hidden,
      keyword_init: true
    )

      def fully_qualified
        [
          *parent&.fully_qualified,
          *identity_components,
        ].compact
      end

      def full_name
        join_names(fully_qualified)
      end

      def literal_name
        if identifiers.empty?
          name.to_s
        else
          join_names(identifiers)
        end
      end

      def type_name
        node_type.name
      end

      def id
        Digest::SHA1.hexdigest(to_h.merge(
          parent: nil,
          identifiers: identifiers&.map(&:id),
          node_type: node_type.name
        ).inspect)[0..6]
      end

      def hidden?
        hidden
      end

      def hide!
        self.hidden = true
      end

      protected

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

      def identity_components
        if identifiers && !identifiers.empty?
          identifiers
        else
          [self]
        end
      end
    end
  end
end

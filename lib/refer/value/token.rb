require "digest/sha1"

module Refer
  module Value
    class Token < Struct.new(
      :name, :identifiers, :node_type, :parent, :file, :line, :column,
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
        Digest::SHA1.hexdigest(Marshal.dump(to_h))[0..6]
      end

      protected

      def join_names(tokens)
        tokens.reduce("") { |s, token|
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

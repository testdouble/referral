require "digest/sha1"

module Refer
  module Value
    class Token < Struct.new(
      :name, :node_type, :parent, :file, :line, :column, keyword_init: true
    )

      def fully_qualified
        if parent
          [*parent.fully_qualified, self]
        else
          [self]
        end
      end

      def full_name
        fully_qualified.reduce("") { |s, token|
          if s.empty?
            token.name
          else
            "#{s}#{token.joiner_syntax}#{token.name}"
          end
        }
      end

      def type_name
        node_type.name
      end

      def id
        Digest::SHA1.hexdigest(Marshal.dump(to_h))[0..6]
      end
    end
  end
end

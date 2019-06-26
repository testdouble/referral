module Referral
  module Value
    class Options < Struct.new(
      # Filtering
      :name,
      :exact_name,
      :full_name,
      :pattern,
      :include_unnamed,
      # Sorting
      :sort,
      # Printing
      :print_headers,
      :columns,
      :delimiter,
      keyword_init: true
    )

      def merge(new_opts)
        self.class.new(to_h.merge(new_opts))
      end
    end
  end
end

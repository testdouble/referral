module Referral
  module Value
    class Options < Struct.new(
      :files,
      # Filtering
      :name,
      :exact_name,
      :full_name,
      :pattern,
      :type,
      :include_unnamed,
      # Sorting
      :sort,
      # Printing
      :print_headers,
      :columns,
      :delimiter,
      keyword_init: true
    )

      def self.default(overrides = {})
        DEFAULT.merge({files: Dir["**/*.rb"]}.merge(overrides))
      end

      DEFAULT = new(
        columns: ["location", "type", "scope", "name"],
        delimiter: " ",
        include_unnamed: false,
        sort: "file",
        print_headers: false,
      ).freeze

      def merge(new_opts)
        self.class.new(to_h.merge(new_opts))
      end
    end
  end
end

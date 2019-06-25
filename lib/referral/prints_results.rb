module Referral
  COLUMNS = {
    location: ->(t) {
      "#{t.file}:#{t.line}:#{t.column}:"
    },
    type_name: ->(t) {
      t.type_name.to_s
    },
    full_name: ->(t) {
      t.full_name.to_s
    },
  }

  class PrintsResults
    def call(result, options)
      result.tokens.each do |t|
        next if t.hidden?
        line_components = [
          COLUMNS[:location].call(t),
          COLUMNS[:type_name].call(t),
          COLUMNS[:full_name].call(t),
        ]
        puts line_components.join(options[:delimiter])
      end
    end
  end
end

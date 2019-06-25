module Referral
  class PrintsResults
    def call(result, options)
      result.tokens.each do |t|
        next if t.hidden?
        line_components = [
          "#{t.file}:#{t.line}:#{t.column}:",
          t.type_name.to_s,
          t.full_name.to_s,
        ]
        puts line_components.join(options[:delimiter])
      end
    end
  end
end

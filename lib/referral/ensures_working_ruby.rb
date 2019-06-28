require "referral/error"

module Referral
  class EnsuresWorkingRuby
    def call
      major, minor = RUBY_VERSION.split(".").map(&:to_i)
      unless major >= 3 || (major == 2 && minor >= 6)
        warn <<-ERROR.gsub(/^ {10}/, "")
          Error: referral must be run with Ruby 2.6 or later, but this is #{RUBY_VERSION}.
                 You can often analyze older Ruby code by running this CLI with a newer
                 Ruby than the code being inspected.

                 Tools like rbenv may help you manage this issue. If you install
                 referral into a supported Ruby, you can specify that it be run with
                 an environment variable, even if the current directory is locked
                 to an older version of Ruby. Just specify the Ruby you want to use:

                 RBENV_VERSION=2.6.3 referral

        ERROR
        raise Referral::Error.new(
          "Unsupported Ruby version (expected 2.6.0 or later, was #{RUBY_VERSION}"
        )
      end
    end
  end
end

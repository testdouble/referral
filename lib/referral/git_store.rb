require "open3"
require "time"

module Referral
  class GitStore
    GROSS_BLAME_CACHE = {}

    def self.sha(file, line)
      return unless (output = blame_line(file, line))
      return unless (match = output.match(/^(\w+)/))
      match[1]
    end

    def self.author(file, line)
      return unless (output = blame_line(file, line))
      return unless (match = output.match(/\(<([^>]*?)>/))
      match[1]
    end

    def self.time(file, line)
      return unless (output = blame_line(file, line))
      return unless (match = output.match(/\(<.*?> (\d+) /))
      Time.at(Integer(match[1]))
    end

    def self.blame_line(file, line)
      return unless (output = blame(file))
      output.split("\n")[line - 1]
    end

    # This format will look like:
    # a50eb722 (<searls@gmail.com> 1561643971 -0400 2) class FirstThing
    # or
    # a50eb722 old/file/path.rb (<searls@gmail.com> 1561643971 -0400 2) class FirstThing
    def self.blame(file)
      GROSS_BLAME_CACHE[file] ||= begin
        out, _, status = Open3.capture3("git blame -e -t \"#{file}\"")
        status.success? ? out : ""
      end
    end
  end
end

module Referral
  class FileStore
    GROSS_FILE_CACHE = {}

    def self.read_line(file, line)
      read_file(file).split("\n")[line - 1]
    end

    def self.read_file(file)
      GROSS_FILE_CACHE[file] ||= File.read(file)
    end
  end
end

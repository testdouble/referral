module Referral
  class ExpandsDirectories
    def call(files_and_directories)
      files_and_directories.flat_map { |f_or_d|
        if File.directory?(f_or_d)
          Dir["#{f_or_d}/**/*.rb"]
        else
          f_or_d
        end
      }
    end
  end
end

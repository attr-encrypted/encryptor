module Encryptor
  # Contains information about this gem's version
  module Version
    MAJOR = 1
    MINOR = 3
    PATCH = 0

    # Returns the full version string
    #
    # Example
    #
    #   Version.to_s # '1.0.2'
    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end

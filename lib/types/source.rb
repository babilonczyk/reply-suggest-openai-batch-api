module Types
  class Source
    EMAIL = "EmailSubmission"
    public_constant :EMAIL

    def self.all
      [ EMAIL ]
    end
  end
end

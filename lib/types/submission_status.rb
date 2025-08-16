module Types
  class SubmissionStatus
    PENDING = "Pending"
    public_constant :PENDING

    APPROVED = "Approved"
    public_constant :APPROVED

    def self.all
      [ PENDING, APPROVED ]
    end
  end
end

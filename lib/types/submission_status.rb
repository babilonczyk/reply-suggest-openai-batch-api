module Types
  class SubmissionStatus
    PENDING = "Pending"
    public_constant :PENDING

    ACCEPTED = "Accepted"
    public_constant :ACCEPTED

    REJECTED = "Rejected"
    public_constant :REJECTED

    def self.all
      [ PENDING, APPROVED, REJECTED ]
    end
  end
end

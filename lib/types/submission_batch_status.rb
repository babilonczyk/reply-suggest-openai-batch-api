module Types
  class SubmissionBatchStatus
    PROCESSING = "processing"
    public_constant :PROCESSING

    COMPLETED = "completed"
    public_constant :COMPLETED

    FAILED = "failed"
    public_constant :FAILED

    def self.all
      [ PROCESSING, COMPLETED, FAILED ]
    end
  end
end

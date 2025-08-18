module SubmissionManagement
  class AcceptSubmission
    def call(submission:)
      return { error: "Submission was not found" } unless submission

      submission.status = Types::SubmissionStatus::ACCEPTED
      submission.save

      return { error: "Failed to accept submission" } unless submission.persisted?

      { submission: submission }
    end
  end
end

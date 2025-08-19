module SubmissionManagement
  class RejectSubmission
    def call(submission:, review_comment:)
      return { error: "Submission was not found" } unless submission
      return { error: "Review comment is required" } if review_comment.blank?

      submission.status = Types::SubmissionStatus::REJECTED
      submission.review_comment = review_comment
      submission.submission_batch_id = nil # reset submission_batch_id to regenerate response with new review comment
      submission.save

      return { error: "Failed to reject submission" } unless submission.persisted?

      { submission: submission }
    end
  end
end

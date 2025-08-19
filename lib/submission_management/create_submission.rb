module SubmissionManagement
  class CreateSubmission
    def call(source:)
      submission = Submission.new

      submission.source = source
      submission.status = Types::SubmissionStatus::PENDING
      submission.content = source.content
      submission.submitted_at = Time.current

      if submission.save
        { submission: submission }
      else
        { error: "Submission creation failed: #{submission.errors.full_messages.join(", ")}" }
      end
    end
  end
end

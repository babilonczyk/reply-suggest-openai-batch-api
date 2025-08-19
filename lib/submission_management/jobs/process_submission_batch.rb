module SubmissionManagement
  module Jobs
    class ProcessSubmissionBatch
      include Sidekiq::Worker

      def perform(options)
        submission_ids = options["submission_ids"]

        puts "### => Processing submission batch for submission_ids: #{submission_ids.join(', ')}"

        # Only process submissions that are not already queued in a batch
        submissions = Submission.where(id: submission_ids, submission_batch_id: nil)

        return if submissions.empty?

        system_message = "You are an AI assistant that generates replies based on the provided context. Please generate a professional reply in the same language."

        batch_data = Core::OpenAi::BatchSubmissionsRequest.new.call(submissions: submissions, system_message: system_message)

        ActiveRecord::Base.transaction do
          submission_batch = SubmissionBatch.new
          submission_batch.batch_id = batch_data["id"]
          submission_batch.status = Types::SubmissionBatchStatus::PROCESSING
          submission_batch.save!

          submissions.update_all(submission_batch_id: submission_batch.id)
        end
      end
    end
  end
end

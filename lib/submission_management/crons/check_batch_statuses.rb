module SubmissionManagement
  module Crons
    class CheckBatchStatuses
      include Sidekiq::Worker

      def perform
        puts "### => Checking all submission batch statuses..."

        SubmissionBatch
          .joins(:submissions)
          .where(submissions: { status: [ Types::SubmissionStatus::PENDING, Types::SubmissionStatus::REJECTED ] })
          .distinct
          .find_in_batches do |batch|
            batch.each do |submission_batch|
              SubmissionManagement::Jobs::CheckSubmissionBatchResults
                .set(queue: "critical")
              .perform_async({ "batch_id" => submission_batch.id })
          end
        end
      end
    end
  end
end

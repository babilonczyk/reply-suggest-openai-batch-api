module SubmissionManagement
  module Crons
    class ProcessAll
      include Sidekiq::Worker

      def perform
        puts "Processing all submissions..."

        Submission.where(status: [ Types::SubmissionStatus::PENDING, Types::SubmissionStatus::REJECTED ]).find_in_batches do |batch|
          batch.each do |submission|
            SubmissionManagement::Jobs::ProcessSubmission.set(queue: "critical").perform_async({ "submission_id" => submission.id })
          end
        end
      end
    end
  end
end

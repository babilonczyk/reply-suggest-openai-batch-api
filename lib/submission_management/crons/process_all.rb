module SubmissionManagement
  module Crons
    class ProcessAll
      include Sidekiq::Worker

      def perform
        puts "### => Processing all submissions..."

        Submission.where(status: [ Types::SubmissionStatus::PENDING, Types::SubmissionStatus::REJECTED ]).find_in_batches do |batch|
          SubmissionManagement::Jobs::ProcessSubmissionBatch.set(queue: "critical").perform_async({ "submission_ids" => batch.map(&:id) })
        end
      end
    end
  end
end

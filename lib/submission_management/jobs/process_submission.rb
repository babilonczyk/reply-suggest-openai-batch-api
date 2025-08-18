module SubmissionManagement
  module Jobs
    class ProcessSubmission
      include Sidekiq::Worker

      def perform(options)
        submission_id = options["submission_id"]

        puts "Processing submission #{submission_id}..."
      end
    end
  end
end

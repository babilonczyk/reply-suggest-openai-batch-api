require "open-uri"
require "json"

module SubmissionManagement
  module Jobs
    class CheckSubmissionBatchResults
      include Sidekiq::Worker

      def perform(options)
        batch_id = options["batch_id"]
        return if batch_id.blank?

        puts "### => Checking submission batch status for batch_id: #{batch_id}"

        client = OpenAI::Client.new
        batch = SubmissionBatch.find_by(id: batch_id)
        return unless batch

        puts "### => Found batch: #{batch.inspect}"

        batch_data = client.batches.retrieve(id: batch.batch_id)

        puts "### => Batch status: #{batch_data['status']}"

        case batch_data["status"]
        when "completed"
          file_url = "https://api.openai.com/v1/files/#{batch_data["output_file_id"]}/content"

          file_content = URI.open(file_url,
            "Authorization" => "Bearer #{ENV["OPENAI_API_KEY"]}"
          ).read

          file_content.each_line do |line|
            parsed = JSON.parse(line)
            submission_id = parsed["custom_id"].sub("submission_", "").to_i

            response = parsed["response"]["body"]["choices"][0]["message"]["content"]

            ActiveRecord::Base.transaction do
              submission = Submission.find_by(id: submission_id)

              submission.update!(generated_reply: response)
            end
          end

          batch.update!(status: Types::SubmissionBatchStatus::COMPLETED)
        when "failed"
          batch.update!(status: Types::SubmissionBatchStatus::FAILED)
          # TODO: Add error reporting
        else
          # Re-enqueue job to try again later
          self.class.perform_in(5.minutes, { "batch_id" => batch_id })
        end
      end
    end
  end
end

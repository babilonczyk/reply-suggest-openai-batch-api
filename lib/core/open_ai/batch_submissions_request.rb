require "openai"
require "tempfile"

module Core
  module OpenAi
    class BatchSubmissionsRequest
      MODEL = "gpt-4o"
      ENDPOINT = "/v1/chat/completions"
      COMPLETION_WINDOW = "24h"

      def call(submissions:, system_message:, window: COMPLETION_WINDOW, model: MODEL)
        jsonl_data = build_jsonl(submissions, system_message)

        client = OpenAI::Client.new

        Tempfile.create([ "batch", ".jsonl" ]) do |file|
          file.write(jsonl_data)
          file.rewind

          upload = client.files.upload(
            parameters: {
              file: Faraday::UploadIO.new(file.path, "text/jsonl"),
              purpose: "batch"
            }
          )

          raise "Upload failed: #{upload['error']&.dig('message')}" unless upload["id"]

          batch = client.batches.create(
            parameters: {
              input_file_id: upload["id"],
              endpoint: ENDPOINT,
              completion_window: COMPLETION_WINDOW
            }
          )

          return batch
        end
      end

      private

      def build_jsonl(submissions, system_message)
        submissions.map do |submission|
          next if submission.content.blank?

          message = system_message.dup
          if submission.status == Types::SubmissionStatus::REJECTED && submission.review_comment.present?
            message << ". Please take review comment into consideration: #{submission.review_comment}"
          end

          {
            custom_id: "submission_#{submission.id}",
            method: "POST",
            url: ENDPOINT,
            body: {
              model: MODEL,
              messages: [
                { role: "system", content: message },
                { role: "user", content: submission.content }
              ]
            }
          }.to_json
        end.compact.join("\n")
      end
    end
  end
end

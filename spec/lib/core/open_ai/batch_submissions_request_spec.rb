# spec/lib/core/open_ai/batch_submissions_request_spec.rb
require "rails_helper"

RSpec.describe Core::OpenAi::BatchSubmissionsRequest do
  subject(:request) { described_class.new }

  let(:system_message)     { "You are a helpful assistant.".freeze }
  let(:submission_content) { "My computer won't start.".freeze }
  let(:review_comment)     { "Please include power status.".freeze }

  let(:submission_id) { 123 }

  let(:model)             { described_class::MODEL }
  let(:endpoint)          { described_class::ENDPOINT }
  let(:completion_window) { described_class::COMPLETION_WINDOW }

  let(:submission) do
    instance_double(
      "Submission",
      id: submission_id,
      content: submission_content,
      status: Types::SubmissionStatus::PENDING,
      review_comment: nil
    )
  end

  let(:rejected_submission) do
    instance_double(
      "Submission",
      id: submission_id,
      content: submission_content,
      status: Types::SubmissionStatus::REJECTED,
      review_comment: review_comment
    )
  end

  let(:upload_id) { "file-abc123" }
  let(:batch_id)  { "batch-xyz789" }

  let(:fake_upload) { { "id" => upload_id } }
  let(:fake_batch)  { { "id" => batch_id } }

  let(:files_api)   { double(upload: fake_upload) }
  let(:batches_api) { double(create: fake_batch) }

  let(:client_double) do
    instance_double(OpenAI::Client, files: files_api, batches: batches_api)
  end

  before do
    allow(OpenAI::Client).to receive(:new).and_return(client_double)
    allow(Faraday::UploadIO).to receive(:new).and_call_original
  end

  describe "#call" do
    it "uploads the file and creates a batch" do
      result = request.call(
        submissions: [ submission ],
        system_message: system_message
      )

      expect(result).to eq(fake_batch)
      expect(OpenAI::Client).to have_received(:new)
      expect(files_api).to have_received(:upload)
      expect(batches_api).to have_received(:create)
    end

    it "raises an error if upload fails" do
      allow(files_api).to receive(:upload).and_return({ "error" => { "message" => "upload failed" } })

      expect {
        request.call(submissions: [ submission ], system_message: system_message)
      }.to raise_error("Upload failed: upload failed")
    end
  end

  describe "#build_jsonl (private)" do
    subject(:jsonl_data) do
      request.send(:build_jsonl, [ rejected_submission ], system_message)
    end

    it "builds valid JSONL with adjusted system message" do
      lines = jsonl_data.split("\n")
      expect(lines.size).to eq(1)

      parsed = JSON.parse(lines.first)

      expect(parsed["custom_id"]).to eq("submission_#{submission_id}")
      expect(parsed["method"]).to eq("POST")
      expect(parsed["url"]).to eq(endpoint)

      body = parsed["body"]
      expect(body["model"]).to eq(model)

      messages = body["messages"]
      expect(messages.size).to eq(2)

      system_msg = messages.first
      user_msg   = messages.last

      expect(system_msg["role"]).to eq("system")
      expect(system_msg["content"]).to include(system_message)
      expect(system_msg["content"]).to include(review_comment)

      expect(user_msg["role"]).to eq("user")
      expect(user_msg["content"]).to eq(submission_content)
    end
  end
end

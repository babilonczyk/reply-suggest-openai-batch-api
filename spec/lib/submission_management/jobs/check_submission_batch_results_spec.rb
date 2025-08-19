require "rails_helper"
require "json"

RSpec.describe SubmissionManagement::Jobs::CheckSubmissionBatchResults, type: :job do
  let(:batch_id) { "openai_batch_123" }

  let(:submission_batch) do
    create(:submission_batch, batch_id: batch_id, status: Types::SubmissionBatchStatus::PROCESSING)
  end

  let!(:submission) do
    create(:submission, :with_email_source,
      id: 42,
      submission_batch: submission_batch,
      status: Types::SubmissionStatus::PENDING,
      content: "Help, my PC is dead.")
  end

  let(:mock_batches) { instance_double("OpenAIBatchInterface") }
  let(:mock_client)  { instance_double(OpenAI::Client, batches: mock_batches) }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(mock_client)
  end

  context "when batch status is 'completed'" do
    let(:mock_batch_response) do
      {
        "status" => "completed",
        "output_file_id" => "file-abc123"
      }
    end

    let(:mock_file_response) do
      # Valid JSONL: no newline at the end
      <<~JSONL.strip
        {"custom_id":"submission_42","response":{"body":{"choices":[{"message":{"content":"Thank you for contacting us. Please try restarting your computer."}}]}}}
      JSONL
    end

    before do
      allow(mock_batches).to receive(:retrieve).with(id: batch_id).and_return(mock_batch_response)
      allow(URI).to receive(:open).and_return(StringIO.new(mock_file_response))
    end

    it "updates the submission with the generated reply and marks batch as completed" do
      described_class.new.perform("batch_id" => submission_batch.id)

      submission.reload
      expect(submission.generated_reply).to eq("Thank you for contacting us. Please try restarting your computer.")
      expect(submission_batch.reload.status).to eq(Types::SubmissionBatchStatus::COMPLETED)
    end
  end

  context "when batch status is 'failed'" do
    before do
      allow(mock_batches).to receive(:retrieve).with(id: batch_id).and_return({ "status" => "failed" })
    end

    it "marks the batch as failed" do
      described_class.new.perform("batch_id" => submission_batch.id)
      expect(submission_batch.reload.status).to eq(Types::SubmissionBatchStatus::FAILED)
    end
  end

  context "when batch status is 'in_progress'" do
    before do
      allow(mock_batches).to receive(:retrieve).with(id: batch_id).and_return({ "status" => "in_progress" })
    end

    it "re-enqueues the job to run again later" do
      expect(described_class).to receive(:perform_in).with(5.minutes, { "batch_id" => submission_batch.id })
      described_class.new.perform("batch_id" => submission_batch.id)
    end
  end

  context "when batch_id is blank" do
    it "does nothing" do
      expect(OpenAI::Client).not_to receive(:new)
      expect(SubmissionBatch).not_to receive(:find_by)

      described_class.new.perform("batch_id" => nil)
    end
  end
end

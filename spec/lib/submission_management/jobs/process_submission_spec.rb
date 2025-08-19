require "rails_helper"

RSpec.describe SubmissionManagement::Jobs::ProcessSubmissionBatch, type: :job do
  let(:job) { described_class.new }

  describe "#perform" do
    let!(:submission1) { create(:submission, :with_email_source, submission_batch_id: nil) }
    let!(:submission2) { create(:submission, :with_email_source, submission_batch_id: nil) }
    let!(:already_batched) { create(:submission, :with_email_source, submission_batch_id: 999) }
    let(:submission_ids) { [ submission1.id, submission2.id, already_batched.id ] }

    let(:fake_batch_response) { { "id" => "batch-xyz123" } }

    before do
      allow(Core::OpenAi::BatchSubmissionsRequest).to receive_message_chain(:new, :call)
        .and_return(fake_batch_response)
    end

    it "creates a SubmissionBatch and assigns it to eligible submissions" do
      expect {
        job.perform({ "submission_ids" => submission_ids })
      }.to change { SubmissionBatch.count }.by(1)

      batch = SubmissionBatch.last
      expect(batch.batch_id).to eq("batch-xyz123")
      expect(batch.status).to eq(Types::SubmissionBatchStatus::PROCESSING)

      expect(submission1.reload.submission_batch_id).to eq(batch.id)
      expect(submission2.reload.submission_batch_id).to eq(batch.id)
      expect(already_batched.reload.submission_batch_id).to eq(999)
    end

    it "does nothing if no eligible submissions" do
      Submission.update_all(submission_batch_id: 123)

      expect {
        job.perform({ "submission_ids" => submission_ids })
      }.not_to change { SubmissionBatch.count }
    end
  end
end

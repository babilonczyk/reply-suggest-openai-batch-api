require "rails_helper"
require "sidekiq/testing"

RSpec.describe SubmissionManagement::Crons::CheckBatchStatuses do
  describe "#perform" do
    before do
      Sidekiq::Worker.clear_all
    end

    let!(:batch_with_pending) do
      create(:submission_batch, batch_id: "batch_pending").tap do |batch|
        create(:submission, :with_email_source, submission_batch: batch, status: Types::SubmissionStatus::PENDING)
      end
    end

    let!(:batch_with_rejected) do
      create(:submission_batch, batch_id: "batch_rejected").tap do |batch|
        create(:submission, :with_email_source, submission_batch: batch, status: Types::SubmissionStatus::REJECTED)
      end
    end

    let!(:batch_with_accepted_only) do
      create(:submission_batch, batch_id: "batch_accepted").tap do |batch|
        create(:submission, :with_email_source, submission_batch: batch, status: Types::SubmissionStatus::ACCEPTED)
      end
    end

    it "enqueues jobs for batches with PENDING or REJECTED submissions" do
      expect {
        described_class.new.perform
      }.to change(SubmissionManagement::Jobs::CheckSubmissionBatchResults.jobs, :size).by(2)

      enqueued_batch_ids = SubmissionManagement::Jobs::CheckSubmissionBatchResults.jobs.map { |job| job["args"].first["batch_id"] }

      expect(enqueued_batch_ids).to include(batch_with_pending.id, batch_with_rejected.id)
      expect(enqueued_batch_ids).not_to include(batch_with_accepted_only.id)
    end
  end
end

require "rails_helper"
require "sidekiq/testing"

RSpec.describe SubmissionManagement::Crons::ProcessAll do
  describe "#perform" do
    before do
      Sidekiq::Worker.clear_all
      Sidekiq::Testing.fake!
    end

    let!(:pending_submission)  { FactoryBot.create(:submission, :with_email_source, status: Types::SubmissionStatus::PENDING) }
    let!(:rejected_submission) { FactoryBot.create(:submission, :with_email_source, status: Types::SubmissionStatus::REJECTED) }
    let!(:accepted_submission) { FactoryBot.create(:submission, :with_email_source, status: Types::SubmissionStatus::ACCEPTED) }

    it "enqueues a job with only PENDING and REJECTED submissions" do
      expect {
        described_class.new.perform
      }.to change(SubmissionManagement::Jobs::ProcessSubmissionBatch.jobs, :size).by(1)

      job = SubmissionManagement::Jobs::ProcessSubmissionBatch.jobs.first
      expect(job["args"].first["submission_ids"]).to match_array([ pending_submission.id, rejected_submission.id ])
      expect(job["args"].first["submission_ids"]).not_to include(accepted_submission.id)
    end
  end
end

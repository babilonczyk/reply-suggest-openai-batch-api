require "rails_helper"
require "sidekiq/testing"

RSpec.describe SubmissionManagement::Crons::ProcessAll do
  describe "#perform" do
    before { Sidekiq::Worker.clear_all }

    let!(:pending_submission)  { FactoryBot.create(:submission, :with_email_source, status: Types::SubmissionStatus::PENDING) }
    let!(:rejected_submission) { FactoryBot.create(:submission, :with_email_source, status: Types::SubmissionStatus::REJECTED) }
    let!(:accepted_submission) { FactoryBot.create(:submission, :with_email_source, status: Types::SubmissionStatus::ACCEPTED) }

    it "enqueues jobs for PENDING and REJECTED submissions only" do
      expect {
        described_class.new.perform
      }.to change(SubmissionManagement::Jobs::ProcessSubmission.jobs, :size).by(2)

      job_args = SubmissionManagement::Jobs::ProcessSubmission.jobs.map { |j| j["args"].first }

      expect(job_args).to include({ "submission_id" => pending_submission.id })
      expect(job_args).to include({ "submission_id" => rejected_submission.id })
      expect(job_args).not_to include({ "submission_id" => accepted_submission.id })
    end
  end
end

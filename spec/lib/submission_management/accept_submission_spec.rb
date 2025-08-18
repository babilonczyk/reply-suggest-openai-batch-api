require "rails_helper"

RSpec.describe SubmissionManagement::AcceptSubmission do
  describe "#call" do
    let(:service) { described_class.new }

    subject { service.call(submission: submission) }

    context "when submission is nil" do
      let(:submission) { nil }

      it "returns an error" do
        result = subject
        expect(result[:error]).to eq("Submission was not found")
      end
    end

    context "when submission exists" do
      let(:submission) { create(:submission, :with_email_source, status: Types::SubmissionStatus::PENDING) }

      context "and save succeeds" do
        it "updates the status to ACCEPTED and returns the submission" do
          result = subject

          expect(result[:submission]).to eq(submission)
          expect(result[:submission].status).to eq(Types::SubmissionStatus::ACCEPTED)
        end
      end

      context "but save fails" do
        before do
          allow(submission).to receive(:status=).with(Types::SubmissionStatus::ACCEPTED)
          allow(submission).to receive(:save).and_return(false)
          allow(submission).to receive(:persisted?).and_return(false)
        end

        it "returns an error" do
          result = subject

          expect(result[:error]).to eq("Failed to accept submission")
        end
      end
    end
  end
end

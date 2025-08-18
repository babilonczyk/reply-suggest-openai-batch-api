require "rails_helper"

RSpec.describe SubmissionManagement::RejectSubmission do
  describe "#call" do
    let(:service) { described_class.new }

    subject { service.call(submission: submission, review_comment: review_comment) }

    context "on success" do
      let(:submission) { FactoryBot.create(:submission, :with_email_source, status: Types::SubmissionStatus::PENDING) }
      let(:review_comment) { "Not relevant to our services." }

      it "updates the submission status to REJECTED and sets the review comment" do
        result = subject
        expect(result[:submission]).to eq(submission)
        expect(result[:submission].status).to eq(Types::SubmissionStatus::REJECTED)
        expect(result[:submission].review_comment).to eq(review_comment)
      end
    end

    context "on failure" do
      context "when submission is nil" do
        let(:submission) { nil }
        let(:review_comment) { "Anything" }

        it "returns an error" do
          result = subject
          expect(result).to eq(error: "Submission was not found")
        end
      end

      context "when review_comment is blank" do
        let(:submission) { FactoryBot.create(:submission, :with_email_source, status: Types::SubmissionStatus::PENDING) }
        let(:review_comment) { "" }

        it "returns an error" do
          result = subject
          expect(result).to eq(error: "Review comment is required")
        end
      end

      context "when save fails" do
        let(:review_comment) { "Not acceptable" }
        let(:submission) do
          instance_double(
            Submission,
            persisted?: false,
            status: Types::SubmissionStatus::PENDING,
            review_comment: nil,
            save: false
          )
        end

        it "returns an error on failed save" do
          allow(submission).to receive(:status=)
          allow(submission).to receive(:review_comment=)

          result = subject

          expect(result[:error]).to eq("Failed to reject submission")
        end
      end
    end
  end
end

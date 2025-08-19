require "rails_helper"

RSpec.describe SubmissionManagement::CreateSubmission do
  describe "#call" do
    let(:service) { described_class.new }

    subject { service.call(source: source) }

    context "on success" do
      let(:source) { FactoryBot.create(:email_submission, message: "Hello", email: "user@example.com") }

      it "creates a Submission linked to the source" do
        result = subject

        expect(result[:submission]).to be_a(Submission)
        expect(result[:submission].source).to eq(source)
        expect(result[:submission].content).to eq(source.content)
        expect(result[:submission].submitted_at).to be_within(1.second).of(Time.current)
        expect(result[:submission]).to be_persisted
      end
    end

    context "on failure" do
      let(:source) { double("EmailSubmission", content: "broken") }
      let(:errors) { double(full_messages: [ "Invalid data" ]) }

      let(:submission_double) { instance_double(Submission) }

      before do
        allow(Submission).to receive(:new).and_return(submission_double)
        allow(submission_double).to receive(:source=)
        allow(submission_double).to receive(:status=)
        allow(submission_double).to receive(:content=)
        allow(submission_double).to receive(:submitted_at=)
        allow(submission_double).to receive(:save).and_return(false)
        allow(submission_double).to receive(:errors).and_return(errors)
      end

      it "returns an error with validation messages" do
        result = subject

        expect(result[:error]).to include("Submission creation failed")
        expect(result[:error]).to include("Invalid data")
      end
    end
  end
end

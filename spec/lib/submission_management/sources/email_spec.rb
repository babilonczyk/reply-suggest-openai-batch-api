require "rails_helper"

RSpec.describe SubmissionManagement::Sources::Email do
  describe "#call" do
    let(:service) { described_class.new }

    let(:email) { "test@example.com" }
    let(:message) { "This is a message" }

    subject { service.call(email: email, message: message) }

    context "on success" do
      context "when both email and message are present" do
        it "creates an EmailSubmission and returns the source" do
          result = subject
          expect(result[:source]).to be_a(EmailSubmission)
          expect(result[:source].email).to eq(email)
          expect(result[:source].message).to eq(message)
          expect(result[:source]).to be_persisted
        end
      end
    end

    context "on failure" do
      context "when email is blank" do
        let(:email) { "" }

        it "returns an error" do
          result = subject
          expect(result).to eq(error: "Email is required")
        end
      end

      context "when message is blank" do
        let(:message) { "" }

        it "returns an error" do
          result = subject
          expect(result).to eq(error: "Message is required")
        end
      end

      context "when save fails" do
        let(:errors) { double(full_messages: [ "Something went wrong" ]) }
        let(:source) { double("EmailSubmission", persisted?: false, errors: errors) }

        it "returns an error with validation messages" do
          allow(EmailSubmission).to receive(:new).and_return(source)
          allow(source).to receive(:message=)
          allow(source).to receive(:email=)
          allow(source).to receive(:save)

          result = subject

          expect(result[:error]).to include("Failed to create email source")
          expect(result[:error]).to include("Something went wrong")
        end
      end
    end
  end
end

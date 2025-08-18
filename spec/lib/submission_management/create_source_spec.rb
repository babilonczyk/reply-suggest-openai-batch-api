require "rails_helper"

RSpec.describe SubmissionManagement::CreateSource do
  describe "#call" do
    let(:service) { described_class.new }

    subject { service.call(source_type: source_type, **params) }

    context "when source_type is valid" do
      let(:email) { "test@example.com" }
      let(:message) { "This is a message" }
      let(:params) { { email: email, message: message } }

      context 'when source_type is EMAIL' do
        let(:source_type) { Types::Source::EMAIL }

        context "and Email source is created successfully" do
          it "returns the EmailSubmission source" do
            result = subject

            expect(result[:source]).to be_a(Hash)
            expect(result[:source][:source]).to be_a(EmailSubmission)
            expect(result[:source][:source].email).to eq(email)
            expect(result[:source][:source].message).to eq(message)
            expect(result[:source][:source]).to be_persisted
          end
        end

        context "and Email source fails to create" do
          before do
            allow(SubmissionManagement::Sources::Email).to receive(:new).and_return(
              double(call: { error: "Some validation failed" })
            )
          end

          it "returns an error message from the source" do
            result = subject
            expect(result).to eq(error: "Failed to create source: Some validation failed")
          end
        end
      end
    end

    context "when source_type is invalid" do
      let(:source_type) { :invalid_type }
      let(:params) { {} }

      it "returns an error about invalid source type" do
        result = subject
        expect(result).to eq(error: "Invalid source type `invalid_type`")
      end
    end
  end
end

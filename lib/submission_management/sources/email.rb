module SubmissionManagement
  module Sources
    class Email
      def call(email:, message:)
        return { error: "Email is required" } if email.blank?
        return { error: "Message is required" } if message.blank?

        email_source = EmailSubmission.new
        email_source.message = message
        email_source.email = email
        email_source.save

        if !email_source.persisted?
          return { error: "Failed to create email source (#{email}): #{email_source.errors.full_messages.join(", ")}" }
        end

        { source: email_source }
      end
    end
  end
end

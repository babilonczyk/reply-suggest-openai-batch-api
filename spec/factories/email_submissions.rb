FactoryBot.define do
  factory :email_submission do
    email { "test@example.com" }
    message { "This is a message" }
  end
end

FactoryBot.define do
  factory :submission do
    status { Types::SubmissionStatus::PENDING }
    content { "This is a test submission content." }
    submitted_at { Time.current }

    trait :with_email_source do
      association :source, factory: :email_submission
    end
  end
end

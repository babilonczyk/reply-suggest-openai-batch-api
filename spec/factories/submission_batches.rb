FactoryBot.define do
  factory :submission_batch do
    batch_id { "batch_#{SecureRandom.hex(4)}" }
    status { Types::SubmissionBatchStatus::PROCESSING }
  end
end

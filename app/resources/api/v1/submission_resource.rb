class Api::V1::SubmissionResource
  include Alba::Resource

  attributes :id, :source_type, :content, :status, :review_comment, :submitted_at, :created_at
end

class EmailSubmission < ApplicationRecord
  has_one :submission, as: :source
end

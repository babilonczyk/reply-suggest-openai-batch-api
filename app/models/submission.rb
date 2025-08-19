class Submission < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :submission_batch, optional: true
end

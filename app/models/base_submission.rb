class BaseSubmission < ApplicationRecord
  self.abstract_class = true

  has_one :submission, as: :source

  def content
    raise NotImplementedError, "Submission sources must implement the content method"
  end
end

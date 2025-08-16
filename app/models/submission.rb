class Submission < ApplicationRecord
  belongs_to :source, polymorphic: true
end

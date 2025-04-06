class Task < ApplicationRecord
  belongs_to :user
  belongs_to :label

  validates :title, presence: true
end

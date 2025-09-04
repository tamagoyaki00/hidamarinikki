class DiaryContent < ApplicationRecord
  belongs_to :diary

  validates :body, presence: true, length: { maximum: 1000 }
end

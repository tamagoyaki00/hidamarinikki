class Diary < ApplicationRecord
  belongs_to :user

  validates :body, presence: true, length: { maximum: 1000}
  validates :posted_date, presence: true

  enum status: { is_public: 0, is_private: 1 }
end

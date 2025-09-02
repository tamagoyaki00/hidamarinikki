class Diary < ApplicationRecord
  belongs_to :user

  validates :body, presence: true, length: { maximum: 1000}
  validates :posted_date, presence: true

  enum status: { is_private: 0, is_public: 1 }
end

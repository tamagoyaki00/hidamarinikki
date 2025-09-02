class Diary < ApplicationRecord
  belongs_to :user

  validates :body, presence: true, length: { maximum: 1000}
  validates :posted_date, presence: true

  enum status: { private: 0, public: 1 }
end

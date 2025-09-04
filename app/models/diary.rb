class Diary < ApplicationRecord
  belongs_to :user
  has_many :diary_contents, dependent: :destroy
  
  validates :happiness_count, presence: true, numericality: { only_integer: true,greater_than_or_equal_to: 0 }
  validates :posted_date, presence: true

  enum :status, { is_public: 0, is_private: 1 }
end

class MonthlyReview < ApplicationRecord
  belongs_to :user
  belongs_to :max_happiness_diary, class_name: "Diary", optional: true


  validates :month, presence: true
  validates :average_happiness_count, numericality: true, allow_nil: true
  validates :max_happiness_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_happiness_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end

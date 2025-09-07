class Diary < ApplicationRecord
  belongs_to :user
  has_many :diary_contents, dependent: :destroy

  has_many_attached :photos do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 200, 200 ]
  end

  validates :happiness_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :posted_date, presence: true

  enum :status, { is_public: 0, is_private: 1 }
end

class Tag < ApplicationRecord
  has_many :diary_tags, dependent: :destroy
  has_many :diaries, through: :diary_tags

  validates :name, presence: true, length: { maximum: 20 }
end

class Tag < ApplicationRecord
  has_many :diary_tags, dependent: :destroy
  has_many :diaries, through: :diary_tags

  validates :name, presence: true, uniqueness: true, length: { maximum: 20 }, blocked_words: true


  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end

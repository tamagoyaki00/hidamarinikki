class DiaryContent < ApplicationRecord
  belongs_to :diary

  validates :body, presence: true, length: { maximum: 1000 }, blocked_words: true

  def self.ransackable_attributes(auth_object = nil)
    %w[body]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  HAPPINESS_IMAGES = [
    "green.png",
    "red.png",
    "star.png",
    "heart.png",
    "clover.png",
    "orange.png"
  ].freeze

  before_save :assign_random_happiness_image

  private

  def assign_random_happiness_image
    self.happiness_image ||= HAPPINESS_IMAGES.sample
  end
end

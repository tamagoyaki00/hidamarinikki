class DiaryContent < ApplicationRecord
  belongs_to :diary

  validates :body, presence: true, length: { maximum: 200 }, blocked_words: true
  validates :jar_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }


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
  before_create :assign_jar_number

  private

  def assign_random_happiness_image
    self.happiness_image ||= HAPPINESS_IMAGES.sample
  end

  def assign_jar_number
    count = DiaryContent.joins(:diary).where(diaries: { user_id: diary.user_id }).count
    self.jar_number = (count / 75) + 1
  end
end

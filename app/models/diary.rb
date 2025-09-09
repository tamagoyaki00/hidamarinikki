class Diary < ApplicationRecord
  belongs_to :user
  has_many :diary_contents, dependent: :destroy
  has_many :diary_tags, dependent: :destroy
  has_many :tags, through: :diary_tags

  has_many_attached :photos do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 200, 200 ]
  end

  validates :happiness_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :posted_date, presence: true

  enum :status, { is_public: 0, is_private: 1 }


  def self.ransackable_attributes(auth_object = nil)
    []
  end

  def self.ransackable_associations(auth_object = nil)
    %w[diary_contents tags]
  end
end

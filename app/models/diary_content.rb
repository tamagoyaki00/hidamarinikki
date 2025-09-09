class DiaryContent < ApplicationRecord
  belongs_to :diary

  validates :body, presence: true, length: { maximum: 1000 }

  def self.ransackable_attributes(auth_object = nil)
    %w[body]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end

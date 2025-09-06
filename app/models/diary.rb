class Diary < ApplicationRecord
  belongs_to :user
  has_many :diary_contents, dependent: :destroy

  has_many_attached :photos do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
  end

  validates :happiness_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :posted_date, presence: true

  enum :status, { is_public: 0, is_private: 1 }

  private

  def validate_photos_format
    if photos.attached? && !photos.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:image, "：ファイル形式が、JPEG, PNG, GIF以外になってます。ファイル形式をご確認ください")
    end
  end

  def photos_size
    if photos.attached? && photos.byte_size > 5.megabytes
      errors.add(:photos, "のファイルサイズは5MB以内にしてください")
    end
  end
end

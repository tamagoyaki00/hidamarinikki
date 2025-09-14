class User < ApplicationRecord
  has_many :diaries, dependent: :destroy
  has_many :diary_contents, through: :diaries, dependent: :destroy

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, presence: true, length: { maximum: 20 }
  validates :uid, uniqueness: { scope: :provider }, if: :provider?
  validate :validate_avatar_format
  validate :avatar_size

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  private

  def validate_avatar_format
    if avatar.attached? && !avatar.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:image, "：ファイル形式が、JPEG, PNG, GIF以外になってます。ファイル形式をご確認ください")
    end
  end

  def avatar_size
    if avatar.attached? && avatar.byte_size > 5.megabytes
      errors.add(:avatar, "のファイルサイズは5MB以内にしてください")
    end
  end
end

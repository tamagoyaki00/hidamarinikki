class User < ApplicationRecord
  before_validation :set_onesignal_external_id, on: :create
  after_create :create_default_notification_setting


  has_many :diaries, dependent: :destroy
  has_many :diary_contents, through: :diaries, dependent: :destroy
  has_one :notification_setting, dependent: :destroy

  has_one_attached :avatar

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, presence: true, length: { maximum: 20 }
  validates :introduction, length: { maximum: 200 }
  validates :uid, uniqueness: { scope: :provider }, if: :provider?
  validate :validate_avatar_format
  validate :avatar_size
  validates :onesignal_external_id, presence: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.onesignal_external_id = SecureRandom.uuid
    end
  end

  def avatar_thumbnail
    self.avatar.variant(resize_to_fill: [ 100, 100 ]).processed
  end

  def diary_streak
    dates = diaries.order(posted_date: :desc).pluck(:posted_date)
    return 0 if dates.empty?

    count = 1
    previous_date = dates.first

    dates.drop(1).each do |date|
      if previous_date - date == 1
        count += 1
        previous_date = date
      else
        break
      end
    end

    count
  end

  private

  def validate_avatar_format
    if avatar.attached? && !avatar.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:avatar, "：ファイル形式が、JPEG, PNG, GIF以外になってます。ファイル形式をご確認ください")
    end
  end

  def avatar_size
    if avatar.attached? && avatar.byte_size > 5.megabytes
      errors.add(:avatar, "のファイルサイズは5MB以内にしてください")
    end
  end

  def set_onesignal_external_id
    self.onesignal_external_id ||= SecureRandom.uuid
  end

  def create_default_notification_setting
    self.create_notification_setting
  end
end

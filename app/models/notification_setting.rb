class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :notification_time, presence: true, if: :reminder_enabled?
  validates :scene_type, presence: true
  validates :scene_name, presence: true, if: -> { scene_type == "custom" }
  enum :scene_type, { preset: 0, custom: 1 }

  validate :notification_time_must_be_15_min_interval

  def notification_time_must_be_15_min_interval
    return unless notification_time
    unless [ 0, 15, 30, 45 ].include?(notification_time.min)
      errors.add(:notification_time, "は15分単位で設定してください")
    end
  end
end

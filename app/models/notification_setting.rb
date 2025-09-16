class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :scene_type, presence: true
  validates :scene_name, presence: true, if: -> { scene_type == 'custom' }
  enum :scene_type, { preset: 0, custom: 1 }
end

class AddIndexToNotificationSettingsNotificationTime < ActiveRecord::Migration[7.2]
  def change
    add_index :notification_settings, :notification_time
  end
end

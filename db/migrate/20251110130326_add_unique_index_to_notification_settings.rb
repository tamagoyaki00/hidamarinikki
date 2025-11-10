class AddUniqueIndexToNotificationSettings < ActiveRecord::Migration[7.2]
  def change
    remove_index :notification_settings, :user_id
    add_index :notification_settings, :user_id, unique: true
  end
end

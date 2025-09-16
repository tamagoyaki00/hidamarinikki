class CreateNotificationSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.time :notification_time
      t.boolean :reminder_enabled, null: false, default: false
      t.integer :scene_type, null: false, default: 0
      t.string :scene_name
      t.timestamps
    end
  end
end

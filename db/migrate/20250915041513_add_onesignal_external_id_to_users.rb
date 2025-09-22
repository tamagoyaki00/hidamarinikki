class AddOnesignalExternalIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :onesignal_external_id, :uuid, null: false
    add_index :users, :onesignal_external_id, unique: true
  end
end

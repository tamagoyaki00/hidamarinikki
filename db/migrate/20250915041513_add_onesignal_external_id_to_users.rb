class AddOnesignalExternalIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :onesignal_external_id, :uuid
  end
end

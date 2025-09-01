class AddOmniauthToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    add_index :users, [:provider, :uid], unique: true, name: "index_users_on_provider_and_uid
  end
end

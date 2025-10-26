class AddHappinessImageToDiaryContents < ActiveRecord::Migration[7.2]
  def change
    add_column :diary_contents, :happiness_image, :string
  end
end

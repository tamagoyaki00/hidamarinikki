class AddJarNumberToDiaryContents < ActiveRecord::Migration[7.2]
  def change
    add_column :diary_contents, :jar_number, :integer, null: false, default: 1
  end
end

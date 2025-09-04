class CreateDiaryContents < ActiveRecord::Migration[7.2]
  def change
    create_table :diary_contents do |t|
      t.references :diary, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end

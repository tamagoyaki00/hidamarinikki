class CreateDiaries < ActiveRecord::Migration[7.2]
  def change
    create_table :diaries do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.integer :happiness_count, default: 0, null: false
      t.date :posted_date, null: false
      t.timestamps
    end

    add_index :diaries, :posted_date
  end
end

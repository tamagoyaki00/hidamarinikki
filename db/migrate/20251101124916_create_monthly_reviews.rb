class CreateMonthlyReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :monthly_reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.date :month, null: false
      t.jsonb :diary_snippets, null: false, default: []
      t.float :average_happiness_count
      t.integer :max_happiness_count
      t.integer :total_happiness_count
      t.date :max_happiness_date

      t.timestamps
    end

    add_index :monthly_reviews, [:user_id, :month], unique: true
  end
end

class DropMonthlyReviews < ActiveRecord::Migration[7.2]
  def change
    drop_table :monthly_reviews
  end
end

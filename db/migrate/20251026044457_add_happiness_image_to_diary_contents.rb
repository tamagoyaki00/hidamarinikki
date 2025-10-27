class AddHappinessImageToDiaryContents < ActiveRecord::Migration[7.2]
  def up
    add_column :diary_contents, :happiness_image, :string

    images = %w[green.png red.png star.png heart.png clover.png orange.png]

    DiaryContent.find_each do |content|
      next if content.happiness_image.present?
      content.update_columns(happiness_image: images.sample)
    end
  end

  def down
    remove_column :diary_contents, :happiness_image
  end

end

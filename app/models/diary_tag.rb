class DiaryTag < ApplicationRecord
  belongs_to :diary
  belongs_to :tag

  validates: diary_id, uniqueness { scope: tag_id }
end
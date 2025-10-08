require 'rails_helper'

RSpec.describe DiaryTag, type: :model do
  let(:diary) { create(:diary) }
  let(:tag)   { create(:tag) }

  describe 'バリデーション' do
    it '同じ diary に同じ tag を2回付けられないこと' do
      create(:diary_tag, diary: diary, tag: tag)
      duplicate = build(:diary_tag, diary: diary, tag: tag)

      expect(duplicate).to be_invalid
      expect(duplicate.errors[:diary_id]).to include('はすでに存在します')
    end

    it '異なる diary なら同じ tag を付けられること' do
      other_diary = create(:diary)
      diary_tag = build(:diary_tag, diary: other_diary, tag: tag)

      expect(diary_tag).to be_valid
    end
  end
end
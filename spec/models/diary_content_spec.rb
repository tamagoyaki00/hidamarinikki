require 'rails_helper'

RSpec.describe DiaryContent, type: :model do
  describe 'バリデーション' do
    context '有効な場合' do
      it '有効なファクトリを持つこと' do
        expect(build(:diary_content)).to be_valid
      end

      it 'body が1000文字ちょうどの場合、有効であること' do
        diary_content = build(:diary_content, body: 'a' * 1000)
        expect(diary_content).to be_valid
      end
    end

    context '無効な場合' do
      it 'bodyが必須であること' do
        diary_content = build(:diary_content, body: nil)
        expect(diary_content).to be_invalid
        expect(diary_content.errors[:body]).to include('を入力してください')
      end

      it 'bodyが空文字（''）であっても無効なこと' do
        diary_content = build(:diary_content, body: '')
        expect(diary_content).to be_invalid
        expect(diary_content.errors[:body]).to include('を入力してください')
      end

      it 'bodyが1001文字以上の場合、無効であること' do
        diary_content = build(:diary_content, body: 'a' * 1001)
        expect(diary_content).to be_invalid
        expect(diary_content.errors[:body]).to include('は1000文字以内で入力してください')
      end
    end
  end
end

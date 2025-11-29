require 'rails_helper'

RSpec.describe DiaryContent, type: :model do
  describe 'バリデーション' do
    context '有効な場合' do
      it '有効なファクトリを持つこと' do
        expect(build(:diary_content)).to be_valid
      end

      it 'body が200文字ちょうどの場合、有効であること' do
        diary_content = build(:diary_content, body: 'a' * 200)
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

      it 'bodyが201文字以上の場合、無効であること' do
        diary_content = build(:diary_content, body: 'a' * 201)
        expect(diary_content).to be_invalid
        expect(diary_content.errors[:body]).to include('は200文字以内で入力してください')
      end

      it '禁止ワードに設定されているワードを日記の内容に入力し投稿した場合、無効であること' do
        invalid_form = build(:diary_form, happiness_items: 'ばかやろう')
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:happiness_items]).to include("に不適切な表現（ばか）が含まれています")
      end
    end
  end

  describe 'メソッド' do
    let(:diary) { create(:diary) }

    it "75件までは jar_number=1" do
      75.times { DiaryContent.create!(diary: diary, body: "test") }
      expect(diary.diary_contents.last.jar_number).to eq(1)
    end

    it "76件目で jar_number=2" do
      76.times { DiaryContent.create!(diary: diary, body: "test") }
      expect(diary.diary_contents.last.jar_number).to eq(2)
    end
  end
end

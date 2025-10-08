require 'rails_helper'

RSpec.describe Diary, type: :model do
  let(:user) { create(:user) }

  describe 'バリデーション' do
    context '有効な場合' do
      it '有効なファクトリを持つこと' do
        diary = build(:diary, user: user)
        expect(diary).to be_valid
      end
    end

    context '無効な場合' do
      it 'happiness_count が必須であること' do
        diary = build(:diary, user: user, happiness_count: nil)
        expect(diary).to be_invalid
        expect(diary.errors[:happiness_count]).to include('を入力してください')
      end

      it 'happiness_count が整数であること' do
        diary = build(:diary, user: user, happiness_count: 1.5)
        expect(diary).to be_invalid
        expect(diary.errors[:happiness_count]).to include('は整数で入力してください')
      end

      it 'happiness_count が0以上であること' do
        diary = build(:diary, user: user, happiness_count: -1)
        expect(diary).to be_invalid
        expect(diary.errors[:happiness_count]).to include('は0以上の値にしてください')
      end

      it 'posted_date が必須であること' do
        diary = build(:diary, user: user, posted_date: nil)
        expect(diary).to be_invalid
        expect(diary.errors[:posted_date]).to include('を入力してください')
      end
    end
  end

  describe 'enum' do
    it 'status が定義されていること' do
      expect(Diary.statuses.keys).to contain_exactly('is_public', 'is_private')
    end

    it 'デフォルトで is_public になること' do
      diary = create(:diary, user: user)
      expect(diary.status).to eq('is_public')
    end
  end
end

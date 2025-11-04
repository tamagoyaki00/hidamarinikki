require 'rails_helper'

RSpec.describe MonthlyReview, type: :model do
  describe 'バリデーション' do
    subject { build(:monthly_review) }

    it '有効なファクトリを持つこと' do
      expect(subject).to be_valid
    end

    context 'month' do
      it '必須であること' do
        subject.month = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:month]).to include("を入力してください")
      end
    end

    context 'average_happiness_count' do
      it '数値の場合、有効であること' do
        subject.average_happiness_count = 2.5
        expect(subject).to be_valid
      end

      it '文字列の場合、無効であること' do
        subject.average_happiness_count = 'abc'
        expect(subject).not_to be_valid
        expect(subject.errors[:average_happiness_count]).to include("は数値で入力してください")
      end

      it 'nil の場合、有効であること' do
        subject.average_happiness_count = nil
        expect(subject).to be_valid
      end
    end

    context 'max_happiness_count' do
      it '0以上の整数の場合、有効であること' do
        subject.max_happiness_count = 3
        expect(subject).to be_valid
      end

      it '負の数の場合、無効であること' do
        subject.max_happiness_count = -1
        expect(subject).not_to be_valid
        expect(subject.errors[:max_happiness_count]).to include("は0以上の値にしてください")
      end

      it '小数の場合、無効であること' do
        subject.max_happiness_count = 1.5
        expect(subject).not_to be_valid
        expect(subject.errors[:max_happiness_count]).to include("は整数で入力してください")
      end

      it 'nil の場合、有効であること' do
        subject.max_happiness_count = nil
        expect(subject).to be_valid
      end
    end

    context 'total_happiness_count' do
      it '0以上の整数の場合、有効であること' do
        subject.total_happiness_count = 8
        expect(subject).to be_valid
      end

      it '負の数の場合、無効であること' do
        subject.total_happiness_count = -2
        expect(subject).not_to be_valid
        expect(subject.errors[:total_happiness_count]).to include("は0以上の値にしてください")
      end

      it '小数の場合、無効であること' do
        subject.total_happiness_count = 2.5
        expect(subject).not_to be_valid
        expect(subject.errors[:total_happiness_count]).to include("は整数で入力してください")
      end

      it 'nil の場合、有効であること' do
        subject.total_happiness_count = nil
        expect(subject).to be_valid
      end
    end
  end

  describe 'アソシエーション' do
    context 'max_happiness_diary がない場合' do
      subject { build(:monthly_review) }

      it '有効であること' do
        expect(subject).to be_valid
      end
    end

    context 'max_happiness_diary がある場合' do
      subject { build(:monthly_review, :with_max_happiness_diary) }

      it '有効であること' do
        expect(subject).to be_valid
        expect(subject.max_happiness_diary).to be_a(Diary)
      end
    end

    context 'user がない場合' do
      subject { build(:monthly_review, user: nil) }

      it '無効であること' do
        expect(subject).not_to be_valid
        expect(subject.errors[:user]).to include("を入力してください")
      end
    end
  end
end
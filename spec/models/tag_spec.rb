require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { build(:tag) }

  describe 'バリデーション' do
    context '有効な場合' do
      it '有効なファクトリなファクトリを持つ場合' do
        expect(tag).to be_valid
      end

      it 'name が20文字の場合、有効であること' do
        tag = build(:tag, name: 'a' * 20 )
        expect(tag).to be_valid
      end
    end

    context '無効な場合' do
      it 'name は必須であること' do
        tag = build(:tag, name: nil)
        expect(tag).to be_invalid
        expect(tag.errors[:name]).to include('を入力してください')
      end

      it 'name は空の場合も無効であること' do
        tag = build(:tag, name: '' )
        expect(tag).to be_invalid
        expect(tag.errors[:name]).to include('を入力してください')
      end

      it 'name は20文字以上の場合、無効であること' do
        tag = build(:tag, name: 'a' * 21 )
        expect(tag).to be_invalid
        expect(tag.errors[:name]).to include('は20文字以内で入力してください')
      end
    end
  end
end
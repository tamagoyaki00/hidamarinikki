require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { build(:tag) }

  describe 'バリデーション' do
    context '有効な場合' do
      it '有効なファクトリなファクトリを持つ場合' do
        expect(tag).to be_valid
      end

      it 'name が20文字の場合、有効であること' do
        tag = build(:tag, name: 'a' * 20)
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
        tag = build(:tag, name: '')
        expect(tag).to be_invalid
        expect(tag.errors[:name]).to include('を入力してください')
      end

      it 'name は21文字以上の場合、無効であること' do
        tag = build(:tag, name: 'a' * 21)
        expect(tag).to be_invalid
        expect(tag.errors[:name]).to include('は20文字以内で入力してください')
      end

      it '禁止ワードに設定されているワードをタグに入力し投稿した場合、無効であること' do
        invalid_form = build(:diary_form, tag_names: '暴力')
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:tag_names]).to include("に不適切な表現（暴力）が含まれています")
      end
    end
  end
end

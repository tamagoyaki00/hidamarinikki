require 'rails_helper'

RSpec.describe DiaryForm, type: :model do
  let(:user) { create(:user) }

  describe 'バリデーション' do
    context '正常系' do
      it '必須項目が揃っていれば有効であること' do
        form = build(:diary_form)
        expect(form).to be_valid
      end

      it 'happiness_items が1000文字以上の場合、有効であること' do
        form = build(:diary_form, happiness_items: [ 'a' * 1000 ])
        expect(form).to be_valid
      end

      it 'タグが10個ちょうどの場合、有効であること' do
        form = build(:diary_form, tag_names: (1..10).map { |i| "tag#{i}" }.join(','))
        expect(form).to be_valid
      end

      it 'タグの文字がちょうど20文字の場合、有効であること' do
        form = build(:diary_form, tag_names: "a" * 20)
        expect(form).to be_valid
      end

      it '写真が6枚ちょうどの場合、有効であること' do
        photos = Array.new(6) { fixture_file_upload('spec/fixtures/files/test.png', 'image/png') }
        form = build(:diary_form, photos: photos)
        expect(form).to be_valid
      end

      it '写真がPNG形式で5MB以内の場合、有効であること' do
        photo = fixture_file_upload('spec/fixtures/files/test.png', 'image/png')
        form = build(:diary_form, photos: [ photo ])
        expect(form).to be_valid
      end
    end

    context '異常系' do
      it 'user_id がないと無効であること' do
        invalid_form = build(:diary_form, user_id: nil)
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:user_id]).to include("を入力してください")
      end

      it 'status がないと無効であること' do
        invalid_form = build(:diary_form, status: nil)
        expect(invalid_form).to be_invalid
      end

      it 'posted_date がないと無効であること' do
        invalid_form = build(:diary_form, posted_date: nil)
        expect(invalid_form).to be_invalid
      end

      it 'happiness_items が全て空だと無効であること' do
        invalid_form = build(:diary_form, happiness_items: [ '' ])
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors.full_messages).to include("少なくとも1つの幸せを入力してください")
      end

      it 'happiness_items が1001文字以上の場合、無効であること' do
        invalid_form = build(:diary_form, happiness_items: [ 'a' * 1001 ])
        expect(invalid_form).to be_invalid
      end

      it '写真が7枚以上だと無効であること' do
        photos = Array.new(7) { fixture_file_upload('spec/fixtures/files/test.png', 'image/png') }
        invalid_form = build(:diary_form, photos: photos)
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:photos]).to include("は6枚以内でアップロードしてください")
      end

      it '写真が非対応形式だと無効であること' do
        photo = fixture_file_upload('spec/fixtures/files/test.txt')
        invalid_form = build(:diary_form, photos: [ photo ])
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:photos]).to include("はJPEG、PNG、GIF形式でアップロードしてください")
      end

      it '写真が5MBを超えると無効であること' do
        photo = fixture_file_upload('spec/fixtures/files/6mb_test.jpeg', 'image/jpeg')
        invalid_form = build(:diary_form, photos: [ photo ])
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:photos]).to include("は1枚あたり5MB以内でアップロードしてください")
      end

      it 'タグが11個以上だと無効であること' do
        invalid_form = build(:diary_form, :with_11tags)
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:tag_names]).to include("は10個以内にしてください")
      end

      it 'タグが20文字を超えると無効であること' do
        invalid_form = build(:diary_form, tag_names: 'a' * 21)
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:tag_names]).to include("は20文字以内で入力してください")
      end

      it '禁止ワードに設定されているワードを日記の内容に入力し投稿した場合、無効であること' do
        invalid_form = build(:diary_form, happiness_items: 'ばかやろう')
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:happiness_items]).to include("に不適切な表現（ばか）が含まれています")
      end

      it '禁止ワードに設定されているワードをタグに入力し投稿した場合、無効であること' do
        invalid_form = build(:diary_form, tag_names: '暴力')
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:tag_names]).to include("に不適切な表現（暴力）が含まれています")
      end

      it '複数の禁止ワードが日記内容に含まれている場合、複数のエラーが表示されること' do
        invalid_form = build(:diary_form, happiness_items: 'ばかやろう。きもい。シネ')
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:happiness_items]).to include("に不適切な表現（ばか）が含まれています")
        expect(invalid_form.errors[:happiness_items]).to include("に不適切な表現（きもい）が含まれています")
        expect(invalid_form.errors[:happiness_items]).to include("に不適切な表現（シネ）が含まれています")
      end
    end
  end

  describe 'インスタンスメソッド' do
    let(:form) { build(:diary_form) }

    it '#valid_happiness_items /空白を除いた配列を返すこと' do
      form = build(:diary_form, happiness_items: [ '楽しい', '', '嬉しい' ])
      expect(form.valid_happiness_items).to eq [ '楽しい', '嬉しい' ]
    end

    it '#happiness_count /有効な happiness_items（日記の項目） の数を返すこと' do
      form = build(:diary_form, happiness_items: [ '楽しい', '嬉しい' ])
      expect(form.happiness_count).to eq 2
    end

    it '#ensure_minimum_fields /最低5件の入力欄が確保されること' do
      form.ensure_minimum_fields(5)
      expect(form.happiness_items.size).to eq 5
    end

    it '#persisted? / diary_id がある場合 true を返す' do
      form = build(:diary_form, diary_id: 1)
      expect(form.persisted?).to be true
    end

    context '#parsed_tags' do
      it 'カンマ区切りで分割されること' do
          form = build(:diary_form, tag_names: 'tag1,tag2,tag3')
          expect(form.send(:parsed_tags)).to eq %w[tag1 tag2 tag3]
      end

      it '空白区切りでも分割されること' do
          form = build(:diary_form, tag_names: 'tag1 tag2   tag3')
          expect(form.send(:parsed_tags)).to eq %w[tag1 tag2 tag3]
      end

      it '重複は除外されること' do
          form = build(:diary_form, tag_names: 'tag1,tag1,tag2')
          expect(form.send(:parsed_tags)).to eq %w[tag1 tag2]
      end
    end
  end
end

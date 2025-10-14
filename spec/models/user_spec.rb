require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe 'バリデーション' do
    it '全ての必須項目が入力されていれば有効' do
      expect(user).to be_valid
    end

    it 'ユーザー新規作成時、onesignal_external_idが自動で設定される' do
      user = create(:user, onesignal_external_id: nil)
      expect(user.onesignal_external_id).to be_present
    end

    it 'name が20文字ちょうどの場合、有効であること' do
      user = build(:user, name: 'a' * 20)
      expect(user).to be_valid
    end

    it 'introduction が200文字ちょうどの場合、有効であること' do
      user = build(:user, introduction: 'a' * 200)
      expect(user).to be_valid
    end

    context '無効な時' do
      it 'nameが必須であること' do
        user = build(:user, name: nil)
        expect(user).to be_invalid
        expect(user.errors.full_messages).to include('ユーザー名を入力してください')
      end

      it 'nameが21文字以上の場合、無効であること' do
        user = build(:user, name: 'a' * 21)
        expect(user).to be_invalid
        expect(user.errors.full_messages).to include('ユーザー名は20文字以内で入力してください')
      end

      it 'introductionが201文字以上の場合、無効であること' do
        user = build(:user, introduction: 'a' * 201)
        expect(user).to be_invalid
        expect(user.errors.full_messages).to include('自己紹介は200文字以内で入力してください')
      end

      context 'アバター画像のフォーマットが正しくない場合' do
        it 'エラーを返すこと' do
          file_path = Rails.root.join('spec/fixtures/files/test.txt')
          user.avatar.attach(io: File.open(file_path), filename: 'test.txt', content_type: 'text/plain')
          expect(user).to be_invalid
          expect(user.errors[:avatar]).to include("：ファイル形式が、JPEG, PNG, GIF以外になってます。ファイル形式をご確認ください")
        end
      end

      it '5MBを超える画像が添付されている場合、無効であること' do
        file_path = Rails.root.join('spec/fixtures/files/6mb_test.jpeg')
        user.avatar.attach(io: File.open(file_path), filename: '6mb_test.jpeg', content_type: 'image/jpeg')
        expect(user).to be_invalid
        expect(user.errors[:avatar]).to include("のファイルサイズは5MB以内にしてください")
      end

      it '禁止ワードに設定されているワードをユーザー名に設定した場合、無効であること' do
        user = build(:user, name: '死ねマン')
        expect(user).to be_invalid
        expect(user.errors[:name]).to include("に不適切な表現（死ね）が含まれています")
      end

      it '禁止ワードに設定されているワードを自己紹介に設定した場合、無効であること' do
        user= build(:user, introduction: '私は、死にたいです。')
        expect(user).to be_invalid
        expect(user.errors[:introduction]).to include('に不適切な表現（死にたい）が含まれています')
      end
    end
  end

  describe 'コールバック' do
    context 'ユーザー作成時' do
      it 'notification_settingが自動で作成される' do
        user = create(:user)
        expect(user.notification_setting).to be_present
      end
    end
  end

  describe 'インスタンスメソッド' do
    let(:user) { create(:user) }

    describe '#diary_streak' do
      context '日記を連日投稿している場合' do
        it '連続日数を正しく返す' do
          create(:diary, user:, posted_date: Date.today)
          create(:diary, user:, posted_date: Date.yesterday)
          create(:diary, user:, posted_date: 3.days.ago)
          expect(user.diary_streak).to eq(2)
        end
      end

      context '投稿がない場合' do
        it '0を返す' do
          expect(user.diary_streak).to eq(0)
        end
      end
    end

    describe '#total_happiness_count' do
      it '全日記のhappiness_count合計を返す' do
        create(:diary, user:, happiness_count: 2)
        create(:diary, user:, happiness_count: 3)
        expect(user.total_happiness_count).to eq(5)
      end

      it '日記を削除すると合計値も減ること' do
        diary1 = create(:diary, user:, happiness_count: 2)
        diary2 = create(:diary, user:, happiness_count: 3)

        expect(user.total_happiness_count).to eq(5)

        diary2.destroy
        expect(user.total_happiness_count).to eq(2)
      end
    end


    describe 'ユーザー削除時' do
      it 'ユーザー削除時に関連する日記も削除されること' do
        user = create(:user)
        diary = create(:diary, user: user)

        expect { user.destroy }.to change(User, :count).by(-1)
                              .and change(Diary, :count).by(-1)
      end
    end
  end
end

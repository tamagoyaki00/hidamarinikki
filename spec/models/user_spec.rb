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

    context '無効な時' do
      it 'nameが存在しない場合、無効であること' do
        user.name = nil
        expect(user).to be_invalid
        expect(user.errors.full_messages).to include('ユーザー名を入力してください')
      end

      it 'nameが21文字以上の場合、無効であること' do
        user.name = 'a' * 21
        expect(user).to be_invalid
        expect(user.errors.full_messages).to include('ユーザー名は20文字以内で入力してください')
      end

      it 'introductionが201文字以上の場合、無効であること' do
        user.introduction = 'a' * 201
        expect(user).to be_invalid
        expect(user.errors.full_messages).to include('自己紹介は200文字以内で入力してください')
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
    end
  end
end


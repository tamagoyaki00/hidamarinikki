require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:notification_setting) { build(:notification_setting) }

  describe 'バリデーション' do
    context '有効な場合' do
      it '有効なファクトリを持つ場合' do
        expect(notification_setting).to be_valid
      end

      it 'notification_time の分が00分の場合、有効であること' do
        notification_time = build(:notification_setting, notification_time: Time.zone.parse('10:00'))
        expect(notification_time).to be_valid
      end
    end

    context '無効な場合' do
      context 'リマインダーが有効な場合' do
        it 'notification_time が存在しない場合、無効なこと' do
          invalid_setting = build(:notification_setting,
                                  reminder_enabled: true,
                                  notification_time: nil)

          expect(invalid_setting).to be_invalid
          expect(invalid_setting.errors.full_messages).to include('設定時間を入力してください')
        end
      end

      it 'scene_type が存在しない場合、無効なこと' do
        invalid_scene_type = build(:notification_setting, scene_type: nil)
        expect(invalid_scene_type).to be_invalid
        expect(invalid_scene_type.errors.full_messages).to include('利用シーンのタイプを入力してください')
      end

      it 'scene_type が custom の場合、scene_name がない場合、無効なこと' do
        invalid_setting = build(:notification_setting, scene_type: :custom, scene_name: nil)
        expect(invalid_setting).to be_invalid
        expect(invalid_setting.errors[:scene_name]).to include('を入力してください')
      end
      it 'notification_time の分が15分単位でない場合、無効なこと' do
        invalid_time_setting = build(:notification_setting, notification_time: Time.zone.parse('10:01'))
        expect(invalid_time_setting).to be_invalid
        expect(invalid_time_setting.errors[:notification_time]).to include('は15分単位で設定してください')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "NotificationSettings", type: :request do
  let(:user) { create(:user) }
  let(:notification_setting) { user.notification_setting }

  describe "GET /notification_settings/edit" do
    context "ログイン済みの場合" do
      before { sign_in user }

      it "200 OK が返ること" do
        get edit_notification_setting_path
        expect(response).to have_http_status(:ok)
      end


      it "通知設定がONに更新されること" do
        patch notification_setting_path,
              params: {
                notification_setting: {
                  reminder_enabled: true,
                  notification_time: "09:00",
                  scene_type: "preset",
                  scene_name: "朝のスタート"
                }
              }


        expect(response).to redirect_to(edit_notification_setting_path)
        expect(notification_setting.reload.reminder_enabled).to eq true
      end

      it "通知設定がOFFに更新されること" do
        patch notification_setting_path,
            params: { notification_setting: { reminder_enabled: false } }

        expect(response).to redirect_to(edit_notification_setting_path)
        expect(notification_setting.reload.reminder_enabled).to eq false
      end
    end

    context "未ログインの場合" do
      it "ログイン画面にリダイレクトされること" do
        get edit_notification_setting_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /notification_settings" do
    before { sign_in user }

    context "有効なパラメータの場合" do
      let(:valid_params) do
        { notification_setting: { reminder_enabled: true, scene_type: "preset", scene_name: "朝のスタート", notification_time: "08:00" } }
      end

      it "通知設定が更新されること" do
        patch notification_setting_path, params: valid_params
        expect(response).to redirect_to(edit_notification_setting_path)
        follow_redirect!
        expect(response.body).to include("通知設定を更新しました")
        expect(notification_setting.reload.reminder_enabled).to eq true
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        { notification_setting: { reminder_enabled: nil, scene_type: nil } }
      end

      it "更新に失敗し、422 Unprocessable Entity が返ること" do
        patch notification_setting_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("通知設定の更新に失敗しました")
      end
    end
  end
end

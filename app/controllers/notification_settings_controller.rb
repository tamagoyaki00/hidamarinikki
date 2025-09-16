class NotificationSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification_setting, only: %i[update edit]

  def edit
  end

  def update
    # 変更前の状態を記録
    previous_state = @notification_setting.reminder_enabled

    if @notification_setting.update(notification_setting_params)
      # 変更後の状態を取得
      current_state = @notification_setting.reminder_enabled

      # 状態変更に応じたメッセージを設定
      if previous_state != current_state
        if current_state
          flash[:notice] = "プッシュ通知をONにしました"
        else
          flash[:notice] = "プッシュ通知をOFFにしました"
        end
      else
        flash[:notice] = "通知設定を確認しました。"
      end

      head :ok
    else
      # バリデーションエラーの場合
      flash[:alert] = "通知設定の保存に失敗しました。#{@notification_setting.errors.full_messages.join('、')}"
      render json: @notification_setting.errors, status: :unprocessable_entity
    end
  end

  private

  def set_notification_setting
      # レコードが存在しなければ作成
      @notification_setting = current_user.notification_setting ||
                          current_user.build_notification_setting(scene_type: :preset)
  end

  def notification_setting_params
    params.require(:notification_setting).permit(:reminder_enabled)
  end
end

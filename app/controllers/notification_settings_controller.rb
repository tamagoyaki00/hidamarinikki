class NotificationSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification_setting, only: %i[update edit]

  def edit
  end

  def update
    if @notification_setting.update(notification_setting_params)
      flash[:notice] = "通知設定を更新しました"
      redirect_to edit_notification_setting_path
    else
      flash[:alert] = "通知設定の更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_notification_setting
      # レコードが存在しなければ作成
      @notification_setting = current_user.notification_setting ||
                          current_user.build_notification_setting(scene_type: :preset)
  end

  def notification_setting_params
    params.require(:notification_setting).permit(:reminder_enabled, :scene_type, :scene_name, :notification_time)
  end
end

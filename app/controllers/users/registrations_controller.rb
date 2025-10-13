# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  def destroy
    external_id = resource.id.to_s

    # OneSignalのユーザー削除
    delete_onesignal_user(current_user.onesignal_external_id)

    super
  end

  private

  def update_resource(resource, params)
    # すべてパスワードなしで更新する
    resource.update_without_password(params.except("current_password"))
  end
  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :avatar ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :avatar, :introduction ])
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  def delete_onesignal_user(external_id)
    uri = URI("https://api.onesignal.com/apps/#{ENV['ONESIGNAL_APP_ID']}/users/by/external_id/#{external_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Delete.new(uri)
    request['Authorization'] = "Key #{ENV['ONESIGNAL_REST_API_KEY']}"

    response = http.request(request)
    Rails.logger.info "OneSignal ユーザー削除リクエスト成功: ステータス=#{response.code}, レスポンス=#{response.body}"
  rescue => e
    Rails.logger.error "OneSignal ユーザー削除リクエスト失敗: #{e.message}"
  end

end

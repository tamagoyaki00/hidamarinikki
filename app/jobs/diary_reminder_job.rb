require "net/http"
require "uri"
require "json"

class DiaryReminderJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "DiaryReminderJob started at #{Time.current.in_time_zone('Asia/Tokyo').strftime('%Y-%m-%d %H:%M:%S %z')}"

    current_time_in_jst = Time.current.in_time_zone("Asia/Tokyo")
    current_hour_minute = current_time_in_jst.strftime("%H:%M")

    # 通知時間が一致するユーザーだけを取得
    users_to_notify = User.joins(:notification_setting)
                      .where(notification_settings: { reminder_enabled: true })
                      .where(notification_settings: { notification_time: current_hour_minute })

    users_to_notify.each do |user|
      if user.onesignal_external_id.present?
        Rails.logger.info "Attempting to send notification to user ID: #{user.id} (External ID: #{user.onesignal_external_id}) for scheduled time: #{user.notification_setting.notification_time.strftime('%H:%M')}"
        send_one_signal_notification(user)
      else
        Rails.logger.warn "User ID: #{user.id} has no OneSignal External ID. Skipping notification."
      end
    end

    Rails.logger.info "DiaryReminderJob finished."
  end

  private

  def send_one_signal_notification(user)
    app_id = ENV["ONESIGNAL_APP_ID"]
    rest_api_key = ENV["ONESIGNAL_REST_API_KEY"]

    unless app_id && rest_api_key
      Rails.logger.error "OneSignal API keys are not set. Check ONESIGNAL_APP_ID and ONESIGNAL_REST_API_KEY."
      return
    end

    uri = URI.parse("https://onesignal.com/api/v1/notifications")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30
    http.open_timeout = 10

    request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
    request["Authorization"] = "Basic #{rest_api_key}"

    payload = {
      app_id: app_id,
      include_external_user_ids: [ user.onesignal_external_id ],
      headings: { "en" => "Diary Reminder 🌞", "ja" => "日記リマインダー 🌸" },
      contents: {
        "en" => "Let's jot down today's happy moments in Hidamari Diary! ✨",
        "ja" => "今日あった良いことを、ひだまり日記に残しませんか？🌼"
      }
    }

    request.body = payload.to_json

    begin
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        Rails.logger.info("OneSignal notification sent to #{user.id}: #{response.body}")
      else
        Rails.logger.error("OneSignal notification failed for #{user.id}: #{response.code} #{response.body}")
      end
    rescue => e
      Rails.logger.error("OneSignal notification error for #{user.id}: #{e.message}")
    end
  end
end

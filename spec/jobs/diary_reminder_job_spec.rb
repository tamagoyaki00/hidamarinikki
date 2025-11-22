require 'rails_helper'

RSpec.describe DiaryReminderJob, type: :job do
let!(:user_on_time) do
  create(:user).tap do |u|
    u.notification_setting.update!(
      reminder_enabled: true,
      notification_time: Time.zone.parse("09:00"),
      scene_type: :preset,
      scene_name: "朝のスタート"
    )
  end
end

  let!(:user_off) { create(:user) }

  it "通知ONかつ時間一致ユーザーのみAPI通信される" do
    job = DiaryReminderJob.new
    allow(job).to receive(:send_one_signal_notification)

    travel_to Time.zone.parse("09:00") do
      job.perform
    end

    expect(job).to have_received(:send_one_signal_notification).with(user_on_time)
  end
end

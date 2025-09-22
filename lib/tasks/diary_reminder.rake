namespace :diary_reminder do
  desc "日記投稿のリマインダーをプッシュ通知する"
  task remind: :environment do
    DiaryReminderJob.perform_now
  end
end

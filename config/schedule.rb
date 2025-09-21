# Rails.rootを使用するために必要
require File.expand_path(File.dirname(__FILE__) + "/environment")
# cronを実行する環境変数周りの設定
ENV.each { |k, v| env(k, v) }
rails_env = ENV["RAILS_ENV"] || :development
# cronを実行する環境変数をセット
set :environment, rails_env

#ログの表示場所
set :output, "log/cron.log"


#一分毎に以下のファイルを実行
every 1.minutes do
  runner "DiaryReminderJob.perform_later"
end

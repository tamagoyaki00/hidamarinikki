# Rails.rootを使用するために必要
require File.expand_path(File.dirname(__FILE__) + "/environment")

# cronを実行する環境変数周りの設定
ENV.each { |k, v| env(k, v) }
rails_env = ENV["RAILS_ENV"] || :development
set :environment, rails_env

# ログ出力
set :output, "/myapp/log/cron.log"

# ジョブ実行にbashを使う
set :job_template, "/bin/bash -l -c ':job'"

# bundle exec rails runner をフルパスで指定
job_type :runner, "cd :path && /usr/local/bundle/bin/bundle exec rails runner -e :environment ':task' :output"

# 1分ごとにジョブ実行
every 1.minutes do
  rake "diary_reminder:remind"
end

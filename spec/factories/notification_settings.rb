FactoryBot.define do
  factory :notification_setting do
    association :user
    notification_time { Time.zone.parse("09:00") }
    reminder_enabled { true }
    scene_type { :preset }
    scene_name { "朝のスタート" }

    trait :custom_scene do
      scene_type { :custom }
      scene_name { "お風呂上り" }
    end
  end
end

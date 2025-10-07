FactoryBot.define do
  factory :diary_content do
    association :diary
    body { "テスト本文" }
  end
end

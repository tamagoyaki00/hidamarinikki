FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "テストタグ#{n}" }
  end
end

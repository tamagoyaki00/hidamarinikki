FactoryBot.define do
  factory :diary_tag do
    association :diary
    association :tag
  end
end
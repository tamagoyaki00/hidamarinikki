FactoryBot.define do
  factory :monthly_review do
    association :user
    month { Date.today.beginning_of_month }
    diary_snippets { [] }
    average_happiness_count { 3.5 }
    max_happiness_count { 5 }
    total_happiness_count { 10 }

    trait :with_max_happiness_diary do
      association :max_happiness_diary, factory: :diary
    end
  end
end
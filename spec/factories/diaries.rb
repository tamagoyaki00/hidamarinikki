FactoryBot.define do
  factory :diary do
    association :user
    posted_date { Date.current }
    happiness_count { 1 }

    trait :private do
      status { :is_private }
    end
  end
end
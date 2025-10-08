FactoryBot.define do
  factory :diary do
    association :user
    posted_date { Date.current }
    happiness_count { 1 }

    trait :private do
      status { :is_private }
    end

    trait :with_tags do
      after(:create) do |diary|
        create_list(:diary_tag, 3, diary: diary)
      end
    end
  end
end
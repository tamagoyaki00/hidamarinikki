FactoryBot.define do
  factory :diary do
    association :user
    posted_date { Date.current }
    happiness_count { 1 }
    status { :is_public }

    trait :private do
      status { :is_private }
    end

    trait :with_tags do
      after(:create) do |diary|
        create_list(:diary_tag, 3, diary: diary)
      end
    end

    trait :with_content do
      transient do
        body_text { 'テスト本文' }
      end

      after(:create) do |diary, evaluator|
        create(:diary_content, diary: diary, body: evaluator.body_text)
      end
    end
  end
end

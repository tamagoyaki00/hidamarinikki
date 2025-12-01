FactoryBot.define do
  factory :diary do
    association :user
    posted_date { Date.current }
    status { :is_public }

    trait :private do
      status { :is_private }
    end

    trait :with_tags do
      transient do
        tag_names { [ 'タグ1', 'タグ2', 'タグ3' ] }
      end

      after(:create) do |diary, evaluator|
        evaluator.tag_names.each do |name|
          tag = create(:tag, name: name)
          create(:diary_tag, diary: diary, tag: tag)
        end
      end
    end

    trait :with_contents do
      transient do
        body_texts { [ '本文1', '本文2', '本文3' ] }
      end

      after(:create) do |diary, evaluator|
        evaluator.body_texts.each do |text|
          create(:diary_content, diary: diary, body: text)
        end
      end
    end


    trait :with_photo do
      after(:create) do |diary|
        diary.photos.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/test.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end

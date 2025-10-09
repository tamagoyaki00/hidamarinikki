FactoryBot.define do
  factory :diary_form do
    user_id { create(:user).id }
    status { "is_public" }
    posted_date { Date.current }
    happiness_items { ["楽しかったこと"] }
    tag_names { "tag1, tag2" }

    trait :with_11tags do
      tag_names { (1..11).map { |i| "tag#{i}" }.join(",") }
    end
  end
end

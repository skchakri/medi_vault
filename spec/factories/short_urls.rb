FactoryBot.define do
  factory :short_url do
    token { "MyString" }
    original_url { "MyText" }
    click_count { 1 }
  end
end

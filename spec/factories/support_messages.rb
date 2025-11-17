FactoryBot.define do
  factory :support_message do
    user { nil }
    message { "MyText" }
    is_admin_response { false }
    parent_id { 1 }
    read_at { "2025-11-16 18:58:29" }
  end
end

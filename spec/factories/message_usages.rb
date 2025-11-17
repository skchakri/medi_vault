FactoryBot.define do
  factory :message_usage do
    user { nil }
    message_type { 1 }
    sent_at { "2025-11-16 14:29:21" }
    status { 1 }
    cost_cents { 1 }
    provider { "MyString" }
    error_message { "MyText" }
  end
end

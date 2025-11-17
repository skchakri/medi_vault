FactoryBot.define do
  factory :payment do
    user { nil }
    stripe_payment_intent_id { "MyString" }
    amount_cents { 1 }
    currency { "MyString" }
    status { 1 }
    description { "MyText" }
    paid_at { "2025-11-16 18:48:42" }
    receipt_url { "MyText" }
  end
end

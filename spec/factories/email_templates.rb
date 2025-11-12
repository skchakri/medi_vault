FactoryBot.define do
  factory :email_template do
    name { "MyString" }
    template_type { "MyString" }
    subject { "MyString" }
    html_body { "MyText" }
    text_body { "MyText" }
    variables { "" }
    active { false }
    created_at { "2025-11-12 12:41:51" }
    updated_at { "2025-11-12 12:41:51" }
  end
end

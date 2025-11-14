# frozen_string_literal: true

puts "🌱 Seeding database..."

# Clear existing data (only in development)
if Rails.env.development?
  puts "🧹 Cleaning existing data..."
  LlmRequest.destroy_all
  Notification.destroy_all
  Alert.destroy_all
  ShareLink.destroy_all
  Credential.destroy_all
  Tag.destroy_all
  ApiSetting.destroy_all
  User.destroy_all
  puts "✅ Existing data cleared"
end

# Create Admin User
puts "\n👤 Creating admin user..."
admin = User.create!(
  email: 'admin@medivault.com',
  password: 'admin123',
  password_confirmation: 'admin123',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin,
  plan: :pro,
  plan_active: true,
  phone: '+14155551234',
  phone_verified: true,
  notification_email: true,
  notification_sms: true,
  confirmed_at: Time.current
)
puts "✅ Admin created: #{admin.email}"

# Create Pro User
puts "\n👤 Creating pro user..."
pro_user = User.create!(
  email: 'pro@medivault.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Sarah',
  last_name: 'Johnson',
  role: :user,
  plan: :pro,
  plan_active: true,
  phone: '+14155552345',
  phone_verified: true,
  npi: '1234567890',
  npi_verified_at: 2.weeks.ago,
  notification_email: true,
  notification_sms: true,
  confirmed_at: Time.current
)
puts "✅ Pro user created: #{pro_user.email}"

# Create Basic User
puts "\n👤 Creating basic user..."
basic_user = User.create!(
  email: 'user@medivault.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'John',
  last_name: 'Doe',
  role: :user,
  plan: :basic,
  plan_active: true,
  npi: '9876543210',
  npi_verified_at: 1.week.ago,
  notification_email: true,
  notification_sms: false,
  confirmed_at: Time.current
)
puts "✅ Basic user created: #{basic_user.email}"

# Create Free User
puts "\n👤 Creating free user..."
free_user = User.create!(
  email: 'free@medivault.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Jane',
  last_name: 'Smith',
  role: :user,
  plan: :free,
  plan_active: true,
  notification_email: true,
  notification_sms: false,
  confirmed_at: Time.current
)
puts "✅ Free user created: #{free_user.email}"

# Create credentials for Pro User
puts "\n📄 Creating credentials for pro user..."

credentials_data = [
  {
    title: 'Medical License - California',
    start_date: 5.years.ago,
    end_date: 1.year.from_now,
    status: :expiring_soon,
    notes: 'Medical Board of California #A12345 - Primary medical license for California practice',
    ai_extracted_json: { issuing_organization: 'Medical Board of California', credential_number: 'A12345' }
  },
  {
    title: 'DEA Registration',
    start_date: 3.years.ago,
    end_date: 2.years.from_now,
    status: :active,
    notes: 'Drug Enforcement Administration #AB1234567 - Required for prescribing controlled substances',
    ai_extracted_json: { issuing_organization: 'Drug Enforcement Administration', credential_number: 'AB1234567' }
  },
  {
    title: 'Board Certification - Internal Medicine',
    start_date: 4.years.ago,
    end_date: 6.years.from_now,
    status: :active,
    notes: 'American Board of Internal Medicine #ABIM-98765 - Board certification in internal medicine',
    ai_extracted_json: { issuing_organization: 'American Board of Internal Medicine', credential_number: 'ABIM-98765' }
  },
  {
    title: 'BLS Certification',
    start_date: 6.months.ago,
    end_date: 18.months.from_now,
    status: :active,
    notes: 'American Heart Association #BLS-2024-001 - Basic Life Support certification',
    ai_extracted_json: { issuing_organization: 'American Heart Association', credential_number: 'BLS-2024-001' }
  },
  {
    title: 'ACLS Certification',
    start_date: 3.months.ago,
    end_date: 21.months.from_now,
    status: :active,
    notes: 'American Heart Association #ACLS-2024-001 - Advanced Cardiac Life Support certification',
    ai_extracted_json: { issuing_organization: 'American Heart Association', credential_number: 'ACLS-2024-001' }
  },
  {
    title: 'Hospital Credentialing - St. Mary\'s',
    start_date: 2.years.ago,
    end_date: 6.months.from_now,
    status: :expiring_soon,
    notes: 'St. Mary\'s Hospital #SMH-DOC-2024 - Hospital privileges at St. Mary\'s Medical Center',
    ai_extracted_json: { issuing_organization: 'St. Mary\'s Hospital', credential_number: 'SMH-DOC-2024' }
  },
  {
    title: 'Malpractice Insurance',
    start_date: 1.year.ago,
    end_date: 11.months.from_now,
    status: :active,
    notes: 'Medical Protective Company #MPC-2024-12345 - Professional liability insurance - $1M/$3M coverage',
    ai_extracted_json: { issuing_organization: 'Medical Protective Company', credential_number: 'MPC-2024-12345' }
  }
]

credentials_data.each do |cred_data|
  credential = pro_user.credentials.create!(cred_data)
  puts "  ✓ Created: #{credential.title} (#{credential.alerts.count} alerts)"
end

# Create credentials for Basic User
puts "\n📄 Creating credentials for basic user..."

basic_credentials = [
  {
    title: 'Nursing License - Texas',
    start_date: 3.years.ago,
    end_date: 9.months.from_now,
    status: :expiring_soon,
    notes: 'Texas Board of Nursing #RN-TX-123456 - Registered Nurse license for Texas',
    ai_extracted_json: { issuing_organization: 'Texas Board of Nursing', credential_number: 'RN-TX-123456' }
  },
  {
    title: 'BLS Certification',
    start_date: 4.months.ago,
    end_date: 20.months.from_now,
    status: :active,
    notes: 'American Heart Association #BLS-2024-456 - Basic Life Support for healthcare providers',
    ai_extracted_json: { issuing_organization: 'American Heart Association', credential_number: 'BLS-2024-456' }
  },
  {
    title: 'PALS Certification',
    start_date: 2.months.ago,
    end_date: 22.months.from_now,
    status: :active,
    notes: 'American Heart Association #PALS-2024-789 - Pediatric Advanced Life Support',
    ai_extracted_json: { issuing_organization: 'American Heart Association', credential_number: 'PALS-2024-789' }
  }
]

basic_credentials.each do |cred_data|
  credential = basic_user.credentials.create!(cred_data)
  puts "  ✓ Created: #{credential.title} (#{credential.alerts.count} alerts)"
end

# Create credentials for Free User
puts "\n📄 Creating credentials for free user..."

free_credentials = [
  {
    title: 'EMT Certification',
    start_date: 1.year.ago,
    end_date: 1.year.from_now,
    status: :active,
    notes: 'National Registry of EMTs #NREMT-B-12345 - Emergency Medical Technician - Basic',
    ai_extracted_json: { issuing_organization: 'National Registry of EMTs', credential_number: 'NREMT-B-12345' }
  }
]

free_credentials.each do |cred_data|
  credential = free_user.credentials.create!(cred_data)
  puts "  ✓ Created: #{credential.title} (#{credential.alerts.count} alerts)"
end

# Create some notifications
puts "\n🔔 Creating sample notifications..."

pro_user.notifications.create!(
  credential: pro_user.credentials.first,
  channel: :email,
  status: :sent,
  content: 'Your Medical License expires in 90 days',
  sent_at: 2.days.ago
)

pro_user.notifications.create!(
  credential: pro_user.credentials.last,
  channel: :email,
  status: :sent,
  content: 'Your Hospital Credentialing expires in 6 months',
  sent_at: 1.week.ago
)

puts "✅ Created #{Notification.count} notifications"

# Create Alert Types
puts "\n🚨 Creating alert types..."

AlertType.create!([
  {
    name: '90 Days Before Expiration',
    offset_days: 90,
    description: 'Alert when a credential expires in 90 days',
    priority: 1,
    notification_channels: ['email'],
    user_plans: ['free', 'basic', 'pro'],
    active: true
  },
  {
    name: '30 Days Before Expiration',
    offset_days: 30,
    description: 'Alert when a credential expires in 30 days',
    priority: 2,
    notification_channels: ['email', 'sms'],
    user_plans: ['free', 'basic', 'pro'],
    active: true
  },
  {
    name: '7 Days Before Expiration',
    offset_days: 7,
    description: 'Urgent alert when a credential expires in 7 days',
    priority: 3,
    notification_channels: ['email', 'sms'],
    user_plans: ['basic', 'pro'],
    active: true
  },
  {
    name: '1 Day Before Expiration',
    offset_days: 1,
    description: 'Critical alert - credential expires tomorrow',
    priority: 4,
    notification_channels: ['email', 'sms'],
    user_plans: ['pro'],
    active: true
  }
])

puts "✅ Created #{AlertType.count} alert types"

# Create Default Tags
puts "\n🏷️  Creating default tags..."

Tag.create!([
  {
    name: 'medical license',
    color: '#3B82F6', # blue
    description: 'Medical licenses and state-specific certifications',
    is_default: true,
    active: true
  },
  {
    name: 'insurance',
    color: '#10B981', # emerald
    description: 'Professional liability and malpractice insurance',
    is_default: true,
    active: true
  },
  {
    name: 'certification',
    color: '#8B5CF6', # violet
    description: 'Professional certifications (BLS, ACLS, PALS, etc.)',
    is_default: true,
    active: true
  },
  {
    name: 'board certification',
    color: '#EF4444', # red
    description: 'Specialty board certifications',
    is_default: true,
    active: true
  },
  {
    name: 'dea license',
    color: '#EC4899', # pink
    description: 'DEA registrations and controlled substance licenses',
    is_default: true,
    active: true
  },
  {
    name: 'hospital privileges',
    color: '#06B6D4', # cyan
    description: 'Hospital credentialing and privileges',
    is_default: true,
    active: true
  },
  {
    name: 'cme credits',
    color: '#F59E0B', # amber
    description: 'Continuing medical education credits',
    is_default: true,
    active: true
  },
  {
    name: 'background check',
    color: '#84CC16', # lime
    description: 'Background checks and clearances',
    is_default: true,
    active: true
  }
])

puts "✅ Created #{Tag.count} default tags"

# Assign tags to existing credentials
puts "\n🔗 Assigning tags to credentials..."

# Tag medical licenses
Credential.where("title ILIKE ?", "%license%").where.not("title ILIKE ?", "%dea%").each do |cred|
  cred.tags << Tag.find_by(name: 'medical license') unless cred.tags.include?(Tag.find_by(name: 'medical license'))
end

# Tag DEA licenses
Credential.where("title ILIKE ?", "%dea%").each do |cred|
  cred.tags << Tag.find_by(name: 'dea license') unless cred.tags.include?(Tag.find_by(name: 'dea license'))
end

# Tag certifications (BLS, ACLS, PALS, EMT)
Credential.where("title ILIKE ? OR title ILIKE ? OR title ILIKE ? OR title ILIKE ?", "%bls%", "%acls%", "%pals%", "%emt%").each do |cred|
  cred.tags << Tag.find_by(name: 'certification') unless cred.tags.include?(Tag.find_by(name: 'certification'))
end

# Tag board certifications
Credential.where("title ILIKE ?", "%board certification%").each do |cred|
  cred.tags << Tag.find_by(name: 'board certification') unless cred.tags.include?(Tag.find_by(name: 'board certification'))
end

# Tag insurance
Credential.where("title ILIKE ?", "%insurance%").each do |cred|
  cred.tags << Tag.find_by(name: 'insurance') unless cred.tags.include?(Tag.find_by(name: 'insurance'))
end

# Tag hospital privileges
Credential.where("title ILIKE ? OR title ILIKE ?", "%hospital%", "%credentialing%").each do |cred|
  cred.tags << Tag.find_by(name: 'hospital privileges') unless cred.tags.include?(Tag.find_by(name: 'hospital privileges'))
end

puts "✅ Tags assigned to credentials"

# Create API Settings
puts "\n⚙️  Creating API settings..."

ApiSetting.create!([
  {
    key: 'npi_api_url',
    value: ENV.fetch('NPI_API_URL', 'https://npiregistry.cms.hhs.gov/api/'),
    enabled: true,
    description: 'NPI Registry API URL for provider verification'
  },
  {
    key: 'npi_api_version',
    value: ENV.fetch('NPI_API_VERSION', '2.1'),
    enabled: true,
    description: 'NPI Registry API Version'
  },
  {
    key: 'openai_api_key',
    value: ENV.fetch('OPENAI_API_KEY', ''),
    enabled: ENV.fetch('OPENAI_API_KEY', '').present?,
    description: 'OpenAI API key for GPT models'
  },
  {
    key: 'ollama_url',
    value: ENV.fetch('OLLAMA_URL', 'http://localhost:11434'),
    enabled: true,
    description: 'Ollama API URL for local AI models'
  },
  {
    key: 'twilio_account_sid',
    value: ENV.fetch('TWILIO_ACCOUNT_SID', ''),
    enabled: ENV.fetch('TWILIO_ACCOUNT_SID', '').present?,
    description: 'Twilio Account SID for SMS notifications'
  },
  {
    key: 'twilio_auth_token',
    value: ENV.fetch('TWILIO_AUTH_TOKEN', ''),
    enabled: ENV.fetch('TWILIO_AUTH_TOKEN', '').present?,
    description: 'Twilio Auth Token'
  },
  {
    key: 'twilio_phone_number',
    value: ENV.fetch('TWILIO_PHONE_NUMBER', ''),
    enabled: ENV.fetch('TWILIO_PHONE_NUMBER', '').present?,
    description: 'Twilio phone number for sending SMS'
  }
])

puts "✅ Created #{ApiSetting.count} API settings"

# Create some sample LLM requests
puts "\n🤖 Creating sample LLM requests..."

3.times do |i|
  pro_user.llm_requests.create!(
    provider: :openai,
    model: 'gpt-4',
    prompt_tokens: rand(100..500),
    completion_tokens: rand(50..200),
    total_tokens: rand(150..700),
    cost_cents: rand(50..300),
    success: true,
    created_at: i.days.ago
  )
end

2.times do |i|
  basic_user.llm_requests.create!(
    provider: :ollama,
    model: 'llama2',
    prompt_tokens: rand(100..500),
    completion_tokens: rand(50..200),
    total_tokens: rand(150..700),
    cost_cents: 0,
    success: true,
    created_at: i.days.ago
  )
end

puts "✅ Created #{LlmRequest.count} LLM requests"

# Load email templates seeder
puts "\n📧 Creating email templates..."
load(Rails.root.join('db/seeds/email_templates.rb'))

# Summary
puts "\n" + "=" * 60
puts "🎉 SEEDING COMPLETE!"
puts "=" * 60
puts "\n📊 Summary:"
puts "  • Users: #{User.count}"
puts "    - Admin: #{User.admin.count}"
puts "    - Regular: #{User.user.count}"
puts "  • Credentials: #{Credential.count}"
puts "  • Tags: #{Tag.count}"
puts "  • Alerts: #{Alert.count}"
puts "  • Alert Types: #{AlertType.count}"
puts "  • Notifications: #{Notification.count}"
puts "  • API Settings: #{ApiSetting.count}"
puts "  • LLM Requests: #{LlmRequest.count}"
puts "\n🔐 Test Accounts:"
puts "  • Admin:  admin@medivault.com / admin123"
puts "  • Pro:    pro@medivault.com / password123"
puts "  • Basic:  user@medivault.com / password123"
puts "  • Free:   free@medivault.com / password123"
puts "\n🌐 Visit: http://localhost:3000"
puts "=" * 60

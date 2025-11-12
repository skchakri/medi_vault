source "https://rubygems.org"

ruby "3.2.2"

gem "rails", "~> 8.0.3"
gem "propshaft" # Asset pipeline
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

# Authentication & Authorization
gem "devise", "~> 4.9"
gem "omniauth-google-oauth2", "~> 1.1"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "pundit", "~> 2.3"

# Background Jobs
gem "sidekiq", "~> 7.2"
gem "sidekiq-cron", "~> 1.12"

# File Storage
gem "aws-sdk-s3", require: false
gem "image_processing", "~> 1.12"

# API & HTTP
gem "httparty", "~> 0.21"
gem "ruby-openai", "~> 6.3"

# Rate Limiting
gem "rack-attack", "~> 6.7"

# SMS
gem "twilio-ruby", "~> 6.9"

# Pagination
gem "kaminari", "~> 1.2"

# Environment Variables
gem "dotenv-rails", "~> 3.0"

# PDF Processing
gem "pdf-reader", "~> 2.12"

# Phone Number Validation
gem "phonelib", "~> 0.8"

# Encryption
gem "lockbox", "~> 2.1"

# Monitoring (optional but recommended)
gem "sentry-ruby", "~> 5.16", require: false
gem "sentry-rails", "~> 5.16", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "pry-rails", "~> 0.3"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener", "~> 1.9"
  gem "letter_opener_web", "~> 2.0"
  # gem "annotate", "~> 3.2" # Not compatible with Rails 8 yet
  # gem "bullet", "~> 7.1" # Not compatible with Rails 8 yet
end

group :test do
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver"
  gem "webmock", "~> 3.23"
  gem "vcr", "~> 6.2"
  gem "shoulda-matchers", "~> 6.2"
  gem "database_cleaner-active_record", "~> 2.1"
end

# MediVault - Professional Credential Management System

MediVault is a comprehensive Rails 8 application for healthcare professionals to securely store, manage, and track their professional credentials with AI-powered extraction and smart expiration alerts.

## Features

### Core Features
- 🔐 **Secure Authentication** - Devise-based user authentication with email confirmation
- 📄 **Credential Management** - Upload and manage professional certificates (PDF/Images)
- 🤖 **AI-Powered Extraction** - Automatic credential data extraction using OpenAI/Ollama
- 🔔 **Smart Alerts** - Customizable expiration alerts (email + SMS)
- 🔗 **Secure Sharing** - Generate one-time share links for credentials
- 📊 **Dashboard** - Overview of all credentials with expiration tracking
- ✅ **NPI Verification** - Verify National Provider Identifier with fuzzy matching

### Technical Stack
- **Rails** 8.0.3
- **Ruby** 3.2.2
- **PostgreSQL** 16
- **Redis** 7
- **Sidekiq** for background jobs
- **Hotwire** (Turbo + Stimulus)
- **Tailwind CSS** for styling
- **Docker** support

### Subscription Plans
- **Free**: 3 credentials, 1 alert per credential, email notifications
- **Basic**: 10 credentials, 3 alerts per credential, email notifications
- **Pro**: 30 credentials, unlimited alerts, email + SMS notifications

## Quick Start with Docker

### 1. Setup Environment

```bash
# Copy environment file
cp .env.example .env

# Generate required keys
docker-compose run --rm web rails secret
# Copy output to SECRET_KEY_BASE in .env

docker-compose run --rm web rails runner "puts Lockbox.generate_key"
# Copy output to LOCKBOX_MASTER_KEY in .env
```

### 2. Start Services

```bash
# Start all services (PostgreSQL, Redis, Web, Sidekiq)
docker-compose up -d

# Create and migrate database
docker-compose exec web rails db:create db:migrate

# (Optional) Seed sample data
docker-compose exec web rails db:seed
```

### 3. Create Admin User

```bash
docker-compose exec web rails console

# In Rails console:
User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin,
  plan: :pro,
  plan_active: true,
  confirmed_at: Time.current
)
```

### 4. Access the Application

- **Web**: http://localhost:3000
- **Sidekiq Dashboard**: http://localhost:3000/admin/sidekiq (admin only)

## Configuration

### Required Environment Variables

```bash
# Database
DB_HOST=db
DB_USERNAME=postgres
DB_PASSWORD=password

# Redis
REDIS_URL=redis://redis:6379/1

# Encryption
LOCKBOX_MASTER_KEY=<generate with Lockbox.generate_key>

# AI (at least one required)
OPENAI_API_KEY=sk-...
# OR
OLLAMA_URL=http://ollama:11434

# SMS (optional - for Pro plan)
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=+1...
```

## Usage

### Upload Credentials

1. Log in to your account
2. Navigate to **Credentials** → **New Credential**
3. Upload a PDF or image file
4. AI will extract information automatically
5. Review and edit the extracted data
6. Save the credential

### Set Up Alerts

1. Open any credential
2. Click **Add Alert**
3. Choose alert timing (1 day, 1 week, 1 month, 2 months, 3 months, 6 months)
4. Alerts will be sent via email (and SMS for Pro users)

### Share Credentials

1. Open any credential
2. Click **Share**
3. Generate a one-time link
4. Send the link via email
5. Link expires after one use or 24 hours

## Database Schema

### Key Models
- **User** - Authentication and profile
- **Credential** - Uploaded certificates/licenses
- **Alert** - Expiration alerts
- **Notification** - Sent notifications
- **ShareLink** - One-time credential sharing
- **ApiSetting** - Admin-configurable settings
- **LlmRequest** - AI usage tracking

## Development

### Local Development (without Docker)

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Start services
rails server                    # Port 3000
bundle exec sidekiq             # Background jobs
rails tailwindcss:watch         # CSS compilation
```

### Running Tests

```bash
# Install test dependencies
bundle install

# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/models/user_spec.rb
```

## Admin Features

Access admin panel at `/admin` (admin users only):

- **Users** - Manage all users, toggle admin status
- **Credentials** - View and manage all credentials
- **API Settings** - Configure OpenAI, Ollama, Twilio, NPI API
- **LLM Requests** - Monitor AI usage and costs
- **Reports** - View usage statistics
- **Sidekiq** - Monitor background jobs

## Troubleshooting

### Database Issues
```bash
# Reset database
docker-compose exec web rails db:reset

# Check database connection
docker-compose exec db psql -U postgres -c '\l'
```

### Sidekiq Issues
```bash
# View Sidekiq logs
docker-compose logs sidekiq

# Restart Sidekiq
docker-compose restart sidekiq
```

### AI Extraction Issues
```bash
# Check LLM requests
docker-compose exec web rails console
> LlmRequest.last

# Verify API keys in admin panel
# Visit http://localhost:3000/admin/api_settings
```

## Deployment

### Production with Docker

```bash
# Build production image
docker build -f Dockerfile -t medi-vault:latest .

# Set production environment variables
# Deploy using your preferred method (AWS ECS, DigitalOcean, etc.)
```

### Required Production Configuration

- Set `RAILS_ENV=production`
- Configure S3 for Active Storage
- Set up SSL/TLS certificates
- Configure SMTP for email delivery
- Set secure `SECRET_KEY_BASE`
- Enable Redis caching

## Security

- All sensitive data encrypted with Lockbox
- Rate limiting via Rack::Attack
- CSRF protection enabled
- SQL injection prevention
- XSS protection
- Secure file uploads

## Support

For issues or questions, please refer to the project documentation or create an issue in the repository.

## License

[Your License Here]

---

**MediVault** - Secure Professional Credential Management

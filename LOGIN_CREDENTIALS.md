# MediVault - Login Credentials

## Test User Accounts

### 1. Regular User (Basic Plan)
- **Email:** `user@medivault.com`
- **Password:** `password123`
- **Role:** User
- **Plan:** Basic
- **Features:**
  - 10 credentials max
  - 3 alerts per credential
  - Email notifications
  - AI extraction
  - Share links

### 2. Admin User (Pro Plan)
- **Email:** `admin@medivault.com`
- **Password:** `admin123`
- **Role:** Admin
- **Plan:** Pro
- **Features:**
  - 30 credentials max
  - 4 alerts per credential
  - Email + SMS notifications
  - AI extraction
  - Share links
  - Full admin panel access at `/admin`
  - User management
  - API settings control
  - LLM usage reports
  - Sidekiq dashboard at `/admin/sidekiq`

### 3. Free User (Free Plan)
- **Email:** `free@medivault.com`
- **Password:** `password123`
- **Role:** User
- **Plan:** Free
- **Features:**
  - 3 credentials max
  - 1 alert per credential
  - Email notifications only
  - AI extraction
  - Basic features

---

## Application URLs

| Page | URL | Authentication Required |
|------|-----|------------------------|
| Home | http://localhost:3000 | No |
| Sign Up | http://localhost:3000/users/sign_up | No |
| Sign In | http://localhost:3000/users/sign_in | No |
| Sign Out | http://localhost:3000/users/sign_out | Yes (DELETE) |
| Dashboard | http://localhost:3000/dashboard | Yes |
| Credentials | http://localhost:3000/credentials | Yes |
| Alerts | http://localhost:3000/alerts | Yes |
| Profile | http://localhost:3000/account/profile | Yes |
| Subscription | http://localhost:3000/account/subscription | Yes |
| Admin Panel | http://localhost:3000/admin | Admin Only |
| Sidekiq | http://localhost:3000/admin/sidekiq | Admin Only |

---

## Authentication Flow

### Sign Up
1. Visit http://localhost:3000/users/sign_up
2. Enter email and password (min 6 characters)
3. Click "Sign up"
4. Account is auto-confirmed (no email verification in dev)
5. Redirected to dashboard

### Sign In
1. Visit http://localhost:3000/users/sign_in
2. Enter email and password
3. Click "Log in"
4. Redirected to dashboard

### Sign Out
1. Click sign out link (DELETE request to /users/sign_out)
2. Session cleared
3. Redirected to home page

---

## Protected Routes

All routes under these paths require authentication:
- `/dashboard`
- `/credentials`
- `/alerts`
- `/notifications`
- `/account/*`
- `/admin/*` (admin role only)

---

## Plan Limits

| Feature | Free | Basic | Pro |
|---------|------|-------|-----|
| Max Credentials | 3 | 10 | 30 |
| Alerts per Credential | 1 | 3 | 4 |
| Email Notifications | ✅ | ✅ | ✅ |
| SMS Notifications | ❌ | ❌ | ✅ |
| AI Extraction | ✅ | ✅ | ✅ |
| Share Links | ✅ | ✅ | ✅ |
| Admin Access | ❌ | ❌ | If role=admin |

---

## Testing Authentication

### Test Sign In
```bash
curl -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@medivault.com",
      "password": "password123"
    }
  }'
```

### Test Sign Up
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "newuser@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "first_name": "New",
      "last_name": "User"
    }
  }'
```

---

## Database Check

View all users:
```bash
bin/rails runner "User.all.each { |u| puts \"#{u.email} - #{u.role} - #{u.plan}\" }"
```

Create a new user:
```bash
bin/rails runner "
User.create!(
  email: 'test@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Test',
  last_name: 'User',
  role: :user,
  plan: :basic,
  plan_active: true,
  confirmed_at: Time.current
)
"
```

---

## Server Status

Rails server is running on: http://localhost:3000
Server PID: Check with `ps aux | grep rails`

To restart server:
```bash
# Kill existing server
pkill -f "rails server"

# Start new server
bin/rails server -b 0.0.0.0 -p 3000
```

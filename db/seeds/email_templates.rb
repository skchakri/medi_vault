# Seed default email templates for MediVault

templates = [
  {
    name: "Welcome Email",
    template_type: "welcome",
    subject: "Welcome to MediVault, {{user_name}}!",
    html_body: <<~HTML,
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px 20px; border-left: 1px solid #e0e0e0; border-right: 1px solid #e0e0e0; }
          .footer { background: #f0f0f0; padding: 20px; text-align: center; border-radius: 0 0 8px 8px; font-size: 12px; color: #666; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Welcome to MediVault!</h1>
            <p>Secure Credential Management for Healthcare Professionals</p>
          </div>
          <div class="content">
            <h2>Hi {{user_name}},</h2>
            <p>Thank you for joining MediVault! Your account has been successfully created and you're ready to start managing your professional credentials securely.</p>
            <p style="text-align: center;">
              <a href="#" class="cta-button">Get Started Now</a>
            </p>
          </div>
          <div class="footer">
            <p>© 2025 MediVault. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    HTML
    text_body: <<~TEXT,
      Welcome to MediVault!
      ===============================================

      Hi {{user_name}},

      Thank you for joining MediVault! Your account has been successfully created and you're ready to start managing your professional credentials securely.

      © 2025 MediVault. All rights reserved.
    TEXT
    variables: ["user_name", "email"],
    active: true
  },
  {
    name: "Email Confirmation",
    template_type: "confirmation_instructions",
    subject: "Confirm Your MediVault Email",
    html_body: <<~HTML,
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px 20px; border-left: 1px solid #e0e0e0; border-right: 1px solid #e0e0e0; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Confirm Your Email</h1>
          </div>
          <div class="content">
            <p>Hi {{user_name}},</p>
            <p>Please confirm your email address to activate your MediVault account.</p>
            <p style="text-align: center;">
              <a href="{{confirmation_link}}" class="cta-button">Confirm Email</a>
            </p>
            <p style="font-size: 12px; color: #666;">If you did not create this account, please ignore this email.</p>
          </div>
        </div>
      </body>
      </html>
    HTML
    text_body: <<~TEXT,
      Confirm Your Email
      ===============================================

      Hi {{user_name}},

      Please confirm your email address to activate your MediVault account.

      Confirm Email: {{confirmation_link}}

      If you did not create this account, please ignore this email.
    TEXT
    variables: ["user_name", "confirmation_link"],
    active: true
  },
  {
    name: "Password Reset",
    template_type: "reset_password_instructions",
    subject: "Reset Your MediVault Password",
    html_body: <<~HTML,
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px 20px; border-left: 1px solid #e0e0e0; border-right: 1px solid #e0e0e0; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Reset Your Password</h1>
          </div>
          <div class="content">
            <p>Hi {{user_name}},</p>
            <p>Someone requested a password reset for your MediVault account. Click the link below to reset your password.</p>
            <p style="text-align: center;">
              <a href="{{reset_link}}" class="cta-button">Reset Password</a>
            </p>
            <p style="font-size: 12px; color: #666;">This link expires in 6 hours. If you didn't request this, please ignore this email.</p>
          </div>
        </div>
      </body>
      </html>
    HTML
    text_body: <<~TEXT,
      Reset Your Password
      ===============================================

      Hi {{user_name}},

      Someone requested a password reset for your MediVault account. Click the link below to reset your password.

      Reset Password: {{reset_link}}

      This link expires in 6 hours. If you didn't request this, please ignore this email.
    TEXT
    variables: ["user_name", "reset_link"],
    active: true
  },
  {
    name: "Email Changed",
    template_type: "email_changed",
    subject: "Your MediVault Email Has Changed",
    html_body: <<~HTML,
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px 20px; border-left: 1px solid #e0e0e0; border-right: 1px solid #e0e0e0; }
          .footer { background: #f0f0f0; padding: 20px; text-align: center; border-radius: 0 0 8px 8px; font-size: 12px; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Email Change Confirmation</h1>
          </div>
          <div class="content">
            <p>Hi {{user_name}},</p>
            <p>We're confirming that your MediVault account email has been changed to {{email}}.</p>
            <p style="font-size: 12px; color: #666;">If you did not make this change, please contact our support team immediately.</p>
          </div>
          <div class="footer">
            <p>© 2025 MediVault. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    HTML
    text_body: <<~TEXT,
      Email Change Confirmation
      ===============================================

      Hi {{user_name}},

      We're confirming that your MediVault account email has been changed to {{email}}.

      If you did not make this change, please contact our support team immediately.

      © 2025 MediVault. All rights reserved.
    TEXT
    variables: ["user_name", "email"],
    active: true
  },
  {
    name: "Account Unlock",
    template_type: "unlock_instructions",
    subject: "Unlock Your MediVault Account",
    html_body: <<~HTML,
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px 20px; border-left: 1px solid #e0e0e0; border-right: 1px solid #e0e0e0; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Unlock Your Account</h1>
          </div>
          <div class="content">
            <p>Hi {{user_name}},</p>
            <p>Your account has been locked due to multiple failed login attempts. Click the link below to unlock your account.</p>
            <p style="text-align: center;">
              <a href="{{unlock_link}}" class="cta-button">Unlock Account</a>
            </p>
            <p style="font-size: 12px; color: #666;">If you did not attempt to sign in, you can safely ignore this email.</p>
          </div>
        </div>
      </body>
      </html>
    HTML
    text_body: <<~TEXT,
      Unlock Your Account
      ===============================================

      Hi {{user_name}},

      Your account has been locked due to multiple failed login attempts. Click the link below to unlock your account.

      Unlock Account: {{unlock_link}}

      If you did not attempt to sign in, you can safely ignore this email.
    TEXT
    variables: ["user_name", "unlock_link"],
    active: true
  },
  {
    name: "Password Changed",
    template_type: "password_change",
    subject: "Your MediVault Password Has Been Changed",
    html_body: <<~HTML,
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px 20px; border-left: 1px solid #e0e0e0; border-right: 1px solid #e0e0e0; }
          .footer { background: #f0f0f0; padding: 20px; text-align: center; border-radius: 0 0 8px 8px; font-size: 12px; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Password Changed</h1>
          </div>
          <div class="content">
            <p>Hi {{user_name}},</p>
            <p>This is a confirmation that your MediVault password has been successfully changed.</p>
            <p style="font-size: 12px; color: #666;">If you did not make this change, please contact our support team immediately.</p>
          </div>
          <div class="footer">
            <p>© 2025 MediVault. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    HTML
    text_body: <<~TEXT,
      Password Changed
      ===============================================

      Hi {{user_name}},

      This is a confirmation that your MediVault password has been successfully changed.

      If you did not make this change, please contact our support team immediately.

      © 2025 MediVault. All rights reserved.
    TEXT
    variables: ["user_name"],
    active: true
  }
]

templates.each do |template_data|
  EmailTemplate.find_or_create_by!(name: template_data[:name]) do |template|
    template.assign_attributes(template_data)
  end
end

puts "✓ Seeded #{templates.count} default email templates"

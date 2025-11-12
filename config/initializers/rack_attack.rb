# frozen_string_literal: true

class Rack::Attack
  ### Throttles ###

  # Limit login attempts per IP
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/users/sign_in' && req.post?
  end

  # Limit registration attempts per IP
  throttle("registrations/ip", limit: 3, period: 1.hour) do |req|
    req.ip if req.path == '/users' && req.post?
  end

  # General request limiting per IP
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  ### Custom Rules ###

  # Block suspicious requests
  blocklist("block bad actors") do |req|
    # Block requests that look like they're probing for vulnerabilities
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('wp-admin') ||
      req.path.include?('wp-login') ||
      req.path.include?('phpMyAdmin')
    end
  end

  ### Response ###

  self.throttled_responder = lambda do |env|
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {
        'Content-Type' => 'text/html',
        'Retry-After' => retry_after.to_s
      },
      ['<html><body><h1>Too Many Requests</h1><p>Please try again later.</p></body></html>']
    ]
  end
end

# Enable Rack::Attack
Rails.application.config.middleware.use Rack::Attack

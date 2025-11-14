# frozen_string_literal: true

# Turbo Native configuration for mobile apps
Rails.application.config.action_controller.before_action do
  # Detect Turbo Native requests
  if request.user_agent.to_s.match?(/Turbo Native/)
    # You can add custom behavior for native apps here
    # For example, different layouts, API responses, etc.
  end
end

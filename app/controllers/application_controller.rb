class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :public_page?

  helper_method :current_plan_name, :plan_limits

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :npi, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end

  def public_page?
    controller_name == 'pages' || controller_name == 'share_links' ||
      (controller_name == 'sessions' && action_name == 'new') ||
      (controller_name == 'registrations' && action_name.in?(['new', 'create']))
  end

  def require_admin!
    unless current_user&.admin?
      flash[:alert] = "You must be an admin to access this page"
      redirect_to root_path
    end
  end

  def current_plan_name
    current_user&.plan&.titleize || 'Free'
  end

  def plan_limits
    {
      free: { credentials: 3, alerts_per_credential: 1 },
      basic: { credentials: 10, alerts_per_credential: 3 },
      pro: { credentials: 30, alerts_per_credential: Float::INFINITY }
    }
  end
end

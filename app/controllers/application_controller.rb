class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :ensure_demo_user
  helper_method :current_user

  private

  def current_user
    @current_user ||= begin
      user = User.find_by(id: session[:user_id]) if session[:user_id].present?
      user ||= User.order(:id).first || create_demo_user!
      session[:user_id] = user.id
      user
    end
  end

  def ensure_demo_user
    current_user if request.format.html?
  end

  def create_demo_user!
    User.create!(
      email: "demo@dreamrails.test",
      encrypted_password: SecureRandom.hex(24),
      username: "dreamer_demo",
      country_code: "IN",
      email_verified_at: Time.current
    ).tap do |user|
      user.transactions.create!(
        amount: User::STARTING_BALANCE,
        transaction_type: "signup_bonus",
        balance_after: user.virtual_balance,
        description: "Signup bonus"
      )
    end
  end
end

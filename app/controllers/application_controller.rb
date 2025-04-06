class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!

  def not_found
    flash[:notice] = "URL NOT FOUND"
    redirect_to root_path
  end

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: "You need to sign in to access this page."
    end
  end

  def user_signed_in?
    session[:user_id].present? && User.exists?(id: session[:user_id])
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  helper_method :current_user, :user_signed_in?
end

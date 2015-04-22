class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  
  # private
  
  def current_user
    @current_user ||= User.find_by_session_token(session[:session_token])
  end
  
  private
  def demand_not_logged_in
    redirect_to root_url if logged_in?
  end

  def logged_in?
    !!current_user
  end

  def log_in!(user)
    @current_user = user
    session[:session_token] = user.reset_token!
  end

  def log_out!
    current_user.try(:reset_token!)
    session[:session_token] = nil
  end

  def require_admin_access!
    render status: 403 unless current_user.is_admin
  end

  def require_logged_in!
    redirect_to new_session_url unless logged_in?
  end

  def require_permission_level! level_required
    levels = current_user.permission_level.to_s(2).split("").reverse.map! do |x|
      x.to_i
    end
    permission = levels[level_required] == 1
    redirect_to new_session_url unless current_user.is_admin || permission
  end
end

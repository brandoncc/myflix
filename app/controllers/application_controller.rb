class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  def current_user
    @current_user || User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_user
    if !logged_in?
      flash[:info] = 'Access reserved for members only. Please sign in first.'
      redirect_to sign_in_path
    end
  end

  def require_admin
    require_user and return if !logged_in?

    redirect_to home_path, flash: {danger: 'You do not have access to that.' } unless current_user && current_user.admin?
  end
end

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
    unless logged_in? && current_user.admin?
      flash[:danger] = 'You do not have access to that.'
      redirect_to home_path
    end
  end

  def require_same_user
    unless logged_in? && current_user == User.find(params[:id])
      flash[:danger] = 'You do not have access to that.'
      redirect_to home_path
    end
  end
end

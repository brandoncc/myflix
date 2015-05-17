class AdminsController < AuthenticatesController 
  before_action :ensure_admin

  def ensure_admin
    if !current_user_is_admin?
      flash['error'] = 'you must be a admin in order to do that'  
      redirect_to root_path
    end    
  end
end
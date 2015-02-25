module SpecTestHelper   
  def login_admin
    login(:admin)
  end

  def login(user)
    user = User.find_by(email: user.email) 
    request.session[:user_id] = user.id
  end

  def current_user
    User.find(request.session[:user_id])
  end

  def login_current_user
    user = Fabricate(:user)
    session[:user_id] = user.id
  end

  def clear_current_session
    session[:user_id] = nil
  end
end
class ResetPasswordController < ApplicationController 
  def show
    @user = User.find_by(reset_token: params[:reset_token])        

    redirect_to token_expire_path unless @user
  end

  def create
    user = User.find_by(reset_token: params[:reset_token])    
    
    user.password = params[:password]
      
    if user.save
      flash[:notice] = 'Password reset done'
      user.clear_reset_token
      redirect_to login_path
    else
      flash[:error] = 'Password must be minimun 5 character'
      redirect_to reset_password_path(reset_token: params[:reset_token])
    end
  end
  

end
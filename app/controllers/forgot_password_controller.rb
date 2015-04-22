class ForgotPasswordController < ApplicationController 
  
  def create
    user = User.find_by(email: params[:email])
    if user 
      AppMailer.forgot_password(user).deliver
      redirect_to confirm_email_send_path
    else
      flash[:error] = 'Cannot find the email in NyfFix system'
      redirect_to forgot_password_path
    end
  end

end 
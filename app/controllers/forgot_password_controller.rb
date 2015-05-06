class ForgotPasswordController < ApplicationController 
  
  def create
    user = User.find_by(email: params[:email])
    if user       

      user.generate_reset_token

      AppMailer.delay.forgot_password(user)
      redirect_to confirm_email_send_path
    else
      flash[:error] = 'Cannot find the email in MyfFix system'
      redirect_to forgot_password_path
    end
  end

end
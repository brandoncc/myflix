class ForgotPasswordsController < ApplicationController
  def create
    if params[:email_address].blank?
      flash[:danger] = 'You must provide an email address so we can send you a password reset email.'
      redirect_to forgot_password_path
    else
      @user = User.find_by(email: params[:email_address])
      if @user
        @user.generate_password_reset_token
        AppMailer.send_password_reset_email(@user).deliver
      end
      flash[:success] = 'If the email address you entered exists in our system, you will receive a password reset link.'
      redirect_to forgot_password_confirmation_path
    end
  end
end

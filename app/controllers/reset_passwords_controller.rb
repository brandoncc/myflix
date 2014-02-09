class ResetPasswordsController < ApplicationController
  def update
    user = User.find_by(password_reset_token: params[:id])

    if user
      user.password = params[:password]

      if user.save
        user.update_column(:password_reset_token, nil)
        flash[:success] = 'Your password was changed successfully. You may now sign in.'
        redirect_to sign_in_path
      else
        flash[:danger] = 'There was a problem changing your password. Please try again.'
        redirect_to reset_password_path(params[:id])
      end
    else
      redirect_to expired_password_reset_token_path
    end
  end
end

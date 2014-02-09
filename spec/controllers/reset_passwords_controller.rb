require 'spec_helper'

describe ResetPasswordsController do
  describe 'PATCH #update' do
    it 'redirects to invalid token page if token is not valid' do
      adam = Fabricate(:user)
      adam.generate_password_reset_token
      patch :update, id: "#{adam.reload.password_reset_token}1"
      expect(response).to redirect_to(expired_password_reset_token_path)
    end

    it 'redirects to sign in page if password is changed successfully' do
      adam = Fabricate(:user)
      adam.generate_password_reset_token
      patch :update, id: "#{adam.reload.password_reset_token}", password: '12345'
      expect(response).to redirect_to(sign_in_path)
    end

    it 'redirects to reset password page if password is not changed successfully' do
      adam = Fabricate(:user)
      adam.generate_password_reset_token
      patch :update, id: "#{adam.reload.password_reset_token}"
      expect(response).to redirect_to(reset_password_path(adam.reload.password_reset_token))
    end

    it 'sets a success message if the password is changed successfully' do
      adam = Fabricate(:user)
      adam.generate_password_reset_token
      patch :update, id: "#{adam.reload.password_reset_token}", password: '12345'
      expect(flash[:success]).to be_present
    end

    it 'sets a failure message if the password if not changed successfully' do
      adam = Fabricate(:user)
      adam.generate_password_reset_token
      patch :update, id: "#{adam.reload.password_reset_token}"
      expect(flash[:danger]).to be_present
    end

    it 'resets the users password to the given password' do
      adam = Fabricate(:user, password: 'password')
      adam.generate_password_reset_token
      patch :update, id: "#{adam.reload.password_reset_token}", password: '12345'
      expect(adam.reload.authenticate('12345')).to be_instance_of(User)
    end

    it 'expires users password reset token' do
      adam = Fabricate(:user, password: 'password')
      adam.generate_password_reset_token
      patch :update, id: "#{adam.reload.password_reset_token}", password: '12345'
      expect(adam.reload.password_reset_token).to be_nil
    end
  end
end

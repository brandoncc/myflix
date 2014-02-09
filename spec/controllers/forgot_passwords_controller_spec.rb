require 'spec_helper'

describe ForgotPasswordsController do
  describe 'POST #create' do
    context 'with existing email address' do
      let(:adam) { Fabricate(:user) }

      before do
        adam.update_column(:password_reset_token, nil)
        ActionMailer::Base.deliveries.clear
        post :create, email_address: adam.email
      end

      it 'redirects to forgot password confirmation if valid' do
        expect(response).to redirect_to(forgot_password_confirmation_path)
      end

      it 'sets success message' do
        expect(flash[:success]).to be_present
      end

      it 'sets @user' do
        expect(assigns(:user)).to eq(adam)
      end

      it 'creates a reset token' do
        expect(adam.reload.password_reset_token).not_to be_nil
      end

      it 'sends password reset email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'with non-existing email address' do
      let(:adam) { Fabricate(:user) }

      before do
        adam.update_column(:password_reset_token, nil)
        ActionMailer::Base.deliveries.clear
        post :create, email_address: "#{adam.email}1"
      end

      it 'sets success message' do
        expect(flash[:success]).to be_present
      end

      it 'does not create a reset token' do
        expect(adam.reload.password_reset_token).to be_nil
      end

      it 'does not send password reset email' do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context 'with blank email address' do
      it 'redirects to the forgot password page' do
        post :create, email_address: ''
        expect(response).to redirect_to(forgot_password_path)
      end

      it 'sets an error message' do
        post :create, email_address: ''
        expect(flash[:danger]).to be_present
      end
    end
  end
end

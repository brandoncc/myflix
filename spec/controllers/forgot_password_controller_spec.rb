require 'rails_helper'

describe ForgotPasswordController do
  describe 'POST Create' do
    before { ActionMailer::Base.deliveries = [] }
    context 'with valid email' do
      it 'sends the email' do
        alice = Fabricate(:user)
        post :create, email: alice.email
        expect(ActionMailer::Base.deliveries.last.to).to eq([alice.email])
      end
      it 'redirect to the confirm page' do
        alice = Fabricate(:user)
        post :create, email: alice.email
        expect(response).to redirect_to confirm_email_send_path
      end

      it 'sets the password token' do
        alice = Fabricate(:user)
        post :create, email: alice.email
        alice.reload
        expect(alice.reset_token).not_to eq(nil)
      end
    end



    context 'with empty email' do
      it 'redirect back to the forgot_password path' do
        post :create, email: ''
        expect(response).to redirect_to forgot_password_path
      end

      it 'errors out' do
        post :create, email: ''
        expect(flash[:error]).to eq('Cannot find the email in MyfFix system')
      end
    end
  end
end
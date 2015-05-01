require 'rails_helper'

describe ResetPasswordController do
  
  describe 'GET Show' do
    context 'with valid token' do
      it 'finds the user' do
        alice = Fabricate(:user, reset_token: '1234')
        get :show, reset_token: '1234'
        expect(assigns(:user)).to eq(alice)
      end
    end

    context 'with invalid token' do
      it 'redirect to token expire path' do
        get :show, reset_token: '123'
        expect(response).to redirect_to token_expire_path
      end
    end
  end

  describe 'POST Create' do
    context 'with valid password' do
      it 'resets the password' do
        alice = Fabricate(:user, reset_token: '1234')
        post :create, password: '1234567', reset_token: '1234' 
        alice.reload
        expect(alice.authenticate('1234567')).to eq(alice)
      end  
      it 'clears the password token' do
        alice = Fabricate(:user, reset_token: '1234')
        post :create, password: '1234567', reset_token: '1234' 
        alice.reload
        expect(alice.reset_token).to eq(nil)
      end
    end

    context 'with invlaid password' do
      it 'redirect to the show path' do
        alice = Fabricate(:user, reset_token: '1234')
        post :create, password: '123', reset_token: '1234' 
        expect(response).to redirect_to reset_password_path(reset_token: alice.reset_token)
      end

      it 'errors out' do      
        alice = Fabricate(:user, reset_token: '1234')
        post :create, password: '123', reset_token: '1234' 
        expect(flash[:error]).to eq("Password must be minimun 5 character")
      end
    end
  end
  
end
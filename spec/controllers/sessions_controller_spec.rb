require 'rails_helper'

describe SessionsController do 
  describe 'GET New' do
    it 'should render the new template' do
      get :new
      response.should render_template :new
    end
  end 

  describe 'POST Create' do
    let(:user) { Fabricate(:user, email: 'example@examplecom', password: '12345') }
    it 'should redirect to homepath when logged in successful' do    
      post :create, email: user.email, password: '12345'
      response.should redirect_to home_path     
    end

    it 'should fail when username not exsit' do
      post :create, email: '1234@1234.com', password: '12344'
      response.should redirect_to login_path
    end
    it 'should fail when password not match' do      
      post :create, email: user.email, password: '12346'
      response.should redirect_to login_path
    end
  end
end
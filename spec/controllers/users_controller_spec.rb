require 'rails_helper'

describe UsersController do 

  describe 'GET New' do
    it 'should create a new instance of User' do
      get :new
      assigns(:user).should be_an_instance_of User
    end
       
  end
  
  describe 'POST Create' do    
    it 'should create user successfuly if registration successful' do
      post :create, user:{email: 'example@123.com', password: '12345'}
      expect(User.count).to eq(1)
    end

    it 'should redirect to sign in path after register' do
      post :create, user:{email: 'example@123.com', password: '12345'}    
      response.should redirect_to login_path
    end
    
    it 'should fail if email is not valid' do 
      post :create, user:{email: '', password: '12345'}
      expect(User.count).to eq(0)
    end
    
    it 'should fail if password is not valid' do
      post :create, user:{email: 'example@example.com', password: '123'}
      expect(User.count).to eq(0)
    end


    context 'sending email' do
      it 'sends the email' do
        post :create, user:{email: 'example@123.com', password: '12345'}    
        expect(ActionMailer::Base.deliveries).not_to eq([])
      end

      it 'sends to the right person' do
        post :create, user:{email: 'example@123.com', password: '12345'}    
        expect(ActionMailer::Base.deliveries.last.to).to eq(['example@123.com'])
      end
      it 'has the correct content' do 
        post :create, user:{email: 'example@123.com', password: '12345', name: 
          'alice'}    
        expect(ActionMailer::Base.deliveries.last.body).to include('alice')
      end
    end

    it 'should faile if email is already been taken' do
      user = User.create(email: 'example@example.com', password: '12345')
      post :create, user:{email: 'example@example.com', password: '12345'}
      response.should render_template :new
    end
  end  

  describe 'GET Show' do
    before { login_current_user }
    let(:user1) { Fabricate(:user)}
    let(:user2) { Fabricate(:user)}
    
    it 'should assign the @user attribute correctly' do
      get :show, id: user1
      expect(assigns(:user)).to eq(user1)
    end

  end
end
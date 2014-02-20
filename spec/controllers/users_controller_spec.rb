require 'spec_helper'

describe UsersController do
  before do
    ActionMailer::Base.deliveries.clear
  end

  describe 'GET #new' do
    it 'should set up @user variable' do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end

    it 'sets up @invite if a valid invite token is provided' do
      adam = Fabricate(:user)
      invite = Fabricate(:invite)
      invite.creator = adam
      invite.save
      get :new, invite: invite.token
      expect(assigns(:invite)).to eq(invite)
    end

    it 'sets up a blank @invite if an invalid invite token is provided' do
      adam = Fabricate(:user)
      invite = Fabricate(:invite)
      invite.creator = adam
      invite.save
      get :new, invite: invite.token + 'wrong'
      expect(assigns(:invite)).to be_a_new(Invite)
    end
  end

  describe 'POST #create' do
    context 'with valid input' do
      it 'creates the user' do
        post :create, user: Fabricate.attributes_for(:user)
        expect(User.count).to eq(1)
      end

      it 'logs user in' do
        post :create, user: Fabricate.attributes_for(:user)
        expect(session[:user_id]).to eq(User.first.id)
      end

      it 'shows success message' do
        post :create, user: Fabricate.attributes_for(:user)
        expect(flash[:success]).not_to be_blank
      end

      it 'redirects to home path' do
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to home_path
      end

      it 'sends welcome email' do
        post :create, user: Fabricate.attributes_for(:user)
        expect(ActionMailer::Base.deliveries).not_to be_empty
      end

      it 'automatically follows inviter, if valid invite token is provided' do
        adam = Fabricate(:user)
        bryan = Fabricate.attributes_for(:user)
        invite = Fabricate(:invite)
        invite.creator = adam
        invite.save
        post :create, user: bryan.merge!(invite: invite.token)
        bryan = User.find_by(email: bryan[:email])
        expect(bryan.follows?(adam)).to eq(true)
      end

      it 'automatically leads inviter, if valid invite token is provided' do
        adam = Fabricate(:user)
        bryan = Fabricate.attributes_for(:user)
        invite = Fabricate(:invite)
        invite.creator = adam
        invite.save
        post :create, user: bryan.merge!(invite: invite.token)
        bryan = User.find_by(email: bryan[:email])
        expect(adam.follows?(bryan)).to eq(true)
      end

      it 'does not automatically follow anybody if invalid invite token is provided' do
        adam = Fabricate(:user)
        invite = Fabricate(:invite)
        invite.creator = adam
        invite.save
        post :create, user: Fabricate.attributes_for(:user).merge!(invite: invite.token + 'wrong')
        expect(adam.followers.count).to eq(0)
      end

      it 'returns user object is authentication passes' do
        adam = Fabricate.attributes_for(:user)
        post :create, user: adam
        expect(assigns(:user).authenticate(adam[:password])).to be_instance_of(User)
      end

      it 'expires invite token after invited user registers' do
        adam = Fabricate(:user)
        invite = Fabricate(:invite)
        invite.creator = adam
        invite.save
        post :create, user: Fabricate.attributes_for(:user).merge!(invite: invite.token)
        expect(invite.reload.token).to be_nil
      end
    end

    context 'with invalid input' do
      before { post :create, user: { email: 'user@example.com', full_name: 'Joe Smith' } }

      it 'does not create the user' do
        expect(User.count).to eq(0)
      end

      it 'renders new template' do
        expect(response).to render_template :new
      end

      it 'sets @user' do
        expect(assigns(:user)).to be_instance_of(User)
      end

      it 'does not send welcome email' do
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it 'displays an error message' do
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe 'GET #show' do
    before { set_current_user }
    it_behaves_like 'an unauthenticated user' do
      let(:action) { get :show, id: 1 }
    end

    it 'sets the @user variable based on the provided id' do
      adam = Fabricate(:user)
      get :show, id: adam.id
      expect(assigns(:user)).to eq(adam)
    end
  end
end

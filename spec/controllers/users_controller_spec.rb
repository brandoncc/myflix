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
    context 'successful user registration' do
      let(:adam) { Fabricate(:user) }
      let(:sign_up_service) {double('sign up service', message: 'Account created successfully, you have been logged in.', successful?: true)}
      before do
        expect(User).to receive(:new).and_return(adam)
        expect_any_instance_of(SignUpService).to receive(:register).and_return(sign_up_service)
      end

      it 'logs user in' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(session[:user_id]).to eq(adam.id)
      end

      it 'shows success message' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(flash[:success]).not_to be_blank
      end

      it 'redirects to home path' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(response).to redirect_to home_path
      end
    end

    context 'failed user registration' do
      let(:sign_up_service) {double('sign up service', message: 'There was a problem creating your account. Please try again.', successful?: false)}
      before do
        expect_any_instance_of(SignUpService).to receive(:register).and_return(sign_up_service)
      end

      it 'renders new template' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(response).to render_template :new
      end

      it 'sets @user' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(assigns(:user)).to be_instance_of(User)
      end

      it 'displays an error message' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
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

  describe 'GET #billing' do
    it_behaves_like 'an unauthenticated user' do
      let(:action) { get :billing }
    end
  end

  describe 'GET #edit' do
    let(:adam) { Fabricate(:user) }

    it_behaves_like 'an unauthenticated user' do
      let(:action) { get :edit, id: adam.id }
    end

    it_behaves_like 'the wrong user' do
      let(:action) { get :edit, id: Fabricate(:user).id }
    end

    it 'sets up @user' do
      set_current_user(adam)
      get :edit, id: adam.id
      expect(assigns(:user)).to eq(adam)
    end
  end

  describe 'POST #update' do
    let(:adam) { Fabricate(:user) }

    it_behaves_like 'an unauthenticated user' do
      let(:action) { get :update, id: adam.id, user: { name: 'AJ' } }
    end

    it_behaves_like 'the wrong user' do
      let(:action) { post :update, id: Fabricate(:user).id, user: { name: 'Cookie Monster' } }
    end

    context 'with valid params' do
      it 'redirects to the users profile' do
        set_current_user(adam)
        post :update, id: adam.id, user: { full_name: 'Snuffalufagus', password: adam.password }
        expect(response).to redirect_to(user_path(adam))
      end

      it 'shows a success message' do
        set_current_user(adam)
        post :update, id: adam.id, user: { full_name: 'Snuffalufagus', password: adam.password }
        expect(flash[:success]).to be_present
      end

      it 'updates the user' do
        set_current_user(adam)
        post :update, id: adam.id, user: { full_name: 'Snuffalufagus', password: adam.password }
        expect(adam.reload.full_name).to eq('Snuffalufagus')
      end
    end

    context 'with invalid params' do
      it 'renders the edit template' do
        set_current_user(adam)
        post :update, id: adam.id, user: { full_name: 'Snuffalufagus' }
        expect(response).to render_template(:edit)
      end

      it 'shows an error message' do
        set_current_user(adam)
        post :update, id: adam.id, user: { full_name: 'Snuffalufagus' }
        expect(flash[:danger]).to be_present
      end

      it 'does not update the user' do
        old_name = adam.full_name
        set_current_user(adam)
        post :update, id: adam.id, user: { full_name: 'Snuffalufagus' }
        expect(adam.reload.full_name).to eq(old_name)
      end
    end
  end
end

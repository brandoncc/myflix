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
    context 'with valid user info and valid card info' do
      before do
        charge = double('charge')
        allow(charge).to receive(:successful?).and_return(true)
        expect(StripeWrapper::Charge).to receive(:create).and_return(charge)
      end

      it 'creates the user' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(User.count).to eq(1)
      end

      it 'logs user in' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(session[:user_id]).to eq(User.first.id)
      end

      it 'shows success message' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(flash[:success]).not_to be_blank
      end

      it 'redirects to home path' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(response).to redirect_to home_path
      end

      it 'sends welcome email' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(ActionMailer::Base.deliveries).not_to be_empty
      end

      it 'automatically follows inviter, if valid invite token is provided' do
        adam = Fabricate(:user)
        bryan = Fabricate.attributes_for(:user)
        invite = Fabricate(:invite)
        invite.creator = adam
        invite.save
        post :create, user: bryan.merge!(invite: invite.token), stripeToken: '123'
        bryan = User.find_by(email: bryan[:email])
        expect(bryan.follows?(adam)).to eq(true)
      end

      it 'automatically leads inviter, if valid invite token is provided' do
        adam = Fabricate(:user)
        bryan = Fabricate.attributes_for(:user)
        invite = Fabricate(:invite)
        invite.creator = adam
        invite.save
        post :create, user: bryan.merge!(invite: invite.token), stripeToken: '123'
        bryan = User.find_by(email: bryan[:email])
        expect(adam.follows?(bryan)).to eq(true)
      end

      it 'does not automatically follow anybody if invalid invite token is provided' do
        adam = Fabricate(:user)
        invite = Fabricate(:invite)
        invite.creator = adam
        invite.save
        post :create, user: Fabricate.attributes_for(:user).merge!(invite: invite.token + 'wrong'), stripeToken: '123'
        expect(adam.followers.count).to eq(0)
      end

      it 'returns user object if authentication passes' do
        adam = Fabricate.attributes_for(:user)
        post :create, user: adam, stripeToken: '123'
        expect(assigns(:user).authenticate(adam[:password])).to be_instance_of(User)
      end

      it 'expires invite token after invited user registers' do
        adam = Fabricate(:user)
        invite = Fabricate(:invite)
        invite.creator = adam
        invite.save
        post :create, user: Fabricate.attributes_for(:user).merge!(invite: invite.token), stripeToken: '123'
        expect(invite.reload.token).to be_nil
      end
    end

    context 'with invalid user info and valid card info' do
      before do
        charge = double('charge')
        allow(charge).to receive(:successful?).and_return(true)
        expect(StripeWrapper::Charge).not_to receive(:create)
      end

      it 'does not create the user' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(User.count).to eq(0)
      end

      it 'renders new template' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(response).to render_template :new
      end

      it 'sets @user' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(assigns(:user)).to be_instance_of(User)
      end

      it 'does not send welcome email' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it 'displays an error message' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(flash[:danger]).to be_present
      end

      it 'does not try to charge the card' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
      end
    end

    context 'with valid user info and invalid card info' do
      before do
        charge = double('charge')
        allow(charge).to receive(:successful?).and_return(false)
        allow(charge).to receive(:error_message).and_return('Your card was declined.')
        expect(StripeWrapper::Charge).to receive(:create).and_return(charge)

        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
      end

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

    context 'with invalid user info and invalid card info' do
      before do
        charge = double('charge')
        allow(charge).to receive(:successful?).and_return(false)
        allow(charge).to receive(:error_message).and_return('Your card was declined.')
        expect(StripeWrapper::Charge).not_to receive(:create)
      end

      it 'does not create the user' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(User.count).to eq(0)
      end

      it 'renders new template' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(response).to render_template :new
      end

      it 'sets @user' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(assigns(:user)).to be_instance_of(User)
      end

      it 'does not send welcome email' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it 'displays an error message' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
        expect(flash[:danger]).to be_present
      end

      it 'does not try to charge the card' do
        post :create, user: Fabricate.attributes_for(:user, password: ''), stripeToken: '123'
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

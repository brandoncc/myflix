require 'spec_helper'

describe InvitesController do
  describe 'GET #new' do
    it 'sets up a blank @invite if user is authenticated' do
      adam = Fabricate(:user)
      session[:user_id] = adam.id
      get :new
      expect(assigns(:invite)).to be_a_new(Invite)
    end

    it_behaves_like 'an unauthenticated user' do
      let(:action) { get :new }
    end
  end

  describe 'POST #create' do
    it_behaves_like 'an unauthenticated user' do
      let(:action) { post :create }
    end

    context 'with valid parameters' do
      it 'creates an invite' do
        set_current_user
        post :create, invite: Fabricate.attributes_for(:invite)
        expect(Invite.count).to eq(1)
      end

      it 'emails invitee a sign up link' do
        ActionMailer::Base.deliveries.clear
        set_current_user
        post :create, invite: Fabricate.attributes_for(:invite)
        expect(ActionMailer::Base.deliveries).not_to be_empty
      end

      it 'redirects to the new invite page' do
        set_current_user
        post :create, invite: Fabricate.attributes_for(:invite)
        expect(response).to redirect_to(new_invites_path)
      end

      it 'shows a success message' do
        set_current_user
        post :create, invite: Fabricate.attributes_for(:invite)
        expect(flash[:success]).to be_present
      end

      it 'shows an error if invited user already exists' do
        adam = Fabricate(:user)
        set_current_user(adam)
        post :create, invite: Fabricate.attributes_for(:invite, email: adam.email)
        expect(flash[:danger]).to be_present
      end

      it 'redirects to the new invite page is invited user already exists' do
        adam = Fabricate(:user)
        set_current_user(adam)
        post :create, invite: Fabricate.attributes_for(:invite, email: adam.email)
        expect(response).to redirect_to(new_invites_path)
      end
    end

    context 'with invalid parameters' do
      it 'renders the new invite page' do
        set_current_user
        post :create, invite: { email: 'joe@email.com' }
        expect(response).to render_template(:new)
      end

      it 'shows an error message' do
        set_current_user
        post :create, invite: { email: 'joe@email.com' }
        expect(flash[:danger]).to be_present
      end
    end
  end
end

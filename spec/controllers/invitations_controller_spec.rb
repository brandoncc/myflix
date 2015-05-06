require 'rails_helper'

describe InvitationsController do
  before do
     login_current_user 
     ActionMailer::Base.deliveries = []
  end
  
  describe 'GET New' do
    it 'sets the invitation instance variable' do
      get :new 
      expect(assigns(:invitation)).to be_a Invitation
    end
  end

  describe 'POST Create' do    
    before do
      request.env["HTTP_REFERER"] = "where_i_came_from"
    end
    
    context 'with valid email' do
      it 'creates the invitation' do
        post :create, invitation:{ email_invited: 'example@123.com', name: 'joe', message: 'check it out' }
        expect(Invitation.count).to eq(1)
      end

      it 'sends out the invitation email' do
        post :create, invitation:{ email_invited: 'example@123.com', name: 'joe', message: 'check it out' }
        expect(ActionMailer::Base.deliveries).not_to eq([])        
      end

    end

    context 'with invalid email' do      
      it 'errors out' do
        alice = Fabricate(:user, name: 'Alice', email: 'alice@example.com')
        post :create, invitation:{ email_invited: alice.email, name: 'joe', message: 'check it out' }
        expect(flash[:error]).to be_present
      end
    end

    context 'without login' do
      it_behaves_like 'require_sign_in' do
        let(:action) { post :create}
      end
    end
  end

  describe 'GET Accept_invitation' do 
    before {clear_current_session}
    let(:alice) {Fabricate(:user)} 
    let(:invitation) {Fabricate(:invitation, user: alice)}

    context 'token valid' do
      # should not trest the template here as it's testing rails default behavior
      # it 'renders the template' do
      #   get :accept_invitation, token: invitation.token
      #   expect(response).to render_template :accept_invitation
      # end

      it 'sets the invitation variable' do
        get :accept_invitation, token: invitation.token
        expect(assigns(:invitation)).to eq(invitation)
      end

      it 'populate the user using invitation' do
        get :accept_invitation, token: invitation.token 
        expect(assigns(:user).email).to eq(invitation.email_invited)
      end
    end

    context 'invalid token' do
      it 'redirect to exprie page' do
        get :accept_invitation, token: '111'
        expect(response).to redirect_to invitation_expire_path
      end
    end
  end
end
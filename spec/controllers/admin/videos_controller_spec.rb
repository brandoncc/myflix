require 'rails_helper'

describe Admin::VideosController do
  describe 'GET New' do
    
    context 'login as non-admin' do
      before { login_current_user }
      it 'redirect to root path' do        
        get :new
        expect(response).to redirect_to root_path
      end

      it 'has error message' do
        get :new
        expect(flash[:error]).to be_present
      end
    end

    context 'login as admin' do
      before { login_admin }
      it 'sets the instance variable correctly' do
        get :new
        expect(assigns(:video)).to be_instance_of(Video)
      end
    end

  end
end
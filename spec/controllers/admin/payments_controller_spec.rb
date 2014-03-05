require 'spec_helper'

describe Admin::PaymentsController do
  describe 'GET #index' do
    context 'user is admin' do
      it 'sets up @payments with all payments in the system' do
        adam = Fabricate(:user, admin: true)
        set_current_user(adam)
        3.times { Fabricate(:payment, user: adam) }
        get :index
        expect(assigns(:payments)).to match_array([adam.payments[0], adam.payments[1], adam.payments[2]])
      end
    end

    context 'user is registered and signed in' do
      it_behaves_like 'a non-admin user' do
        let(:action) { get :index }
      end
    end

    context 'user is not signed in' do
      it_behaves_like 'an unauthenticated user' do
        let(:action) { get :index }
      end
    end
  end
end

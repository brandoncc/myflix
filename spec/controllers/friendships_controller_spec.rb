require 'rails_helper'

describe FriendshipsController do 
  before do
    login_current_user
  end
  let(:user1) { Fabricate(:user)}
  let(:user2) { Fabricate(:user)}
  let(:user3) { Fabricate(:user)}
  describe 'GET Index' do
    it 'should set the correct @friendships attribute' do
      friendship = current_user.friendships.build(friend: user2)
      friendship2 = current_user.friendships.build(friend: user3)
      friendship.save
      friendship2.save

      get :index
      expect(assigns(:friendships).map(&:friend)).to eq([user3, user2])
    end

    it 'should render the correct template' do
      get :index
      response.should render_template :index
    end

    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { get :index }
      end
    end        

  end


end
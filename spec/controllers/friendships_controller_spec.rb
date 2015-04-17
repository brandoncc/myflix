require 'rails_helper'

describe FriendshipsController do 
  before do
    login_current_user
  end
  let(:user1) { Fabricate(:user)}
  let(:user2) { Fabricate(:user)}
  let(:user3) { Fabricate(:user)}
  describe 'GET Index' do
    it 'sets the correct @friendships attribute' do
      friendship = current_user.friendships.build(friend: user2)
      friendship2 = current_user.friendships.build(friend: user3)
      friendship.save
      friendship2.save

      get :index
      expect(assigns(:friendships).map(&:friend)).to eq([user3, user2])
    end

  
    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { get :index }
      end
    end        

  end

  describe 'DELETE Destroy' do
    before do
      request.env["HTTP_REFERER"] = "where_i_came_from"
    end
    it 'deletes the friendship if follower is current user' do
      friendship = Fabricate(:friendship, follower: current_user, friend: user2 ) 
      delete :destroy, id: friendship
      expect(current_user.friendships.size).to eq(0)
      
    end

    it 'does not delete the friendship if the follower is not the current user' do
      friendship = user1.friendships.build(friend: user2)      
      friendship.save

      delete :destroy, id: friendship
      expect(user1.friendships.size).to eq(1)    
    end
  end


  describe 'POST Create' do
    before do
      request.env["HTTP_REFERER"] = "where_i_came_from"
    end
    it 'create the friendship correctly' do 
      post :create, id: user1
      expect(current_user.friendships.map(&:friend)).to eq([user1])
    end

    it 'should not create the frienship twice' do
      post :create, id: user1
      post :create, id: user1
      expect(current_user.friendships.map(&:friend)).to eq([user1])
    end

    it 'should not create the friendship for the user itself' do

      post :create, id: current_user
      expect(current_user.friendships.size).to eq(0)
    end
    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { post :create, id: user1 }
      end
    end

  end


end
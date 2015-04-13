class FriendshipsController < ApplicationController 
  before_action :require_user
  
  def index
    @friendships = current_user.friendships if current_user  
  end
  
  def destroy
    friendship = Friendship.find(params[:id])
    friendship.destroy if friendship.follower == current_user
    redirect_to friendships_path
  end

  def create
    friendship = Friendship.find_by(user_id: current_user.id, friend_id: params[:id])
    if friendship.nil?
      friend = User.find(params[:id])
      Friendship.create(user_id: current_user.id, friend_id: params[:id]) if friend
    end    
    redirect_to :back
  end
end
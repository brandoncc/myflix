class FriendshipsController < ApplicationController 
  before_action :require_user
  
  def index
    @friendships = current_user.friendships if current_user  
  end
  
  def destroy
    friendship = Friendship.find(params[:id])
    friendship.destroy if friendship.follower == current_user
    redirect_to :back
  end

  def create    
    friend = User.find_by_token(params[:id])
    Friendship.create(user_id: current_user.id, friend_id: friend.id) if current_user.can_follow?(friend)

    redirect_to :back
  end
end 
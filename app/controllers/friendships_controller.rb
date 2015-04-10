class FriendshipsController < ApplicationController 
  before_action :require_user
  
  def index
    @friendships = current_user.friendships if current_user  
  end
  
end
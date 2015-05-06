class UsersController < ApplicationController
  before_action :require_user, only: [:show]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.handle_invitation(params[:token])
      AppMailer.delay.welcome_letter(@user)
      redirect_to login_path
    else
      render :new
    end
  end

  def show
    @user = User.find_by(token: params[:id])
    @friendship = Friendship.find_by(user_id: current_user.id, friend_id: @user.id)
  end

  def user_params
    params.require(:user).permit(:email, :password, :name)
  end    
end
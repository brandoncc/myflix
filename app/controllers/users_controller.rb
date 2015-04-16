class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to login_path
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])

    @friendship = Friendship.find_by(user_id: current_user.id, friend_id: params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :name)
  end
end
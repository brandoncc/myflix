class UsersController < ApplicationController
  before_action :require_user, only: :update_queue

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      flash[:success] =
        'Account created successfully, you have been logged in.'
      redirect_to home_path
    else
      render :new
    end
  end

  def update_queue
    if current_user.reorder_queue_items(queue_items_with_valid_position) &&
        current_user.update_queue_item_ratings(queue_items_with_valid_rating)
      flash[:success] = 'Your queue has been updated successfully.'
    else
      flash[:danger] =
        'There was a problem updating your queue. Please try again.'
    end

    redirect_to :back
  end

  private

  def queue_items_with_valid_rating
    params[:user][:queue_item]
    .select { |_, v|v.include?(:rating) }
    .delete_if { |_, v| v[:rating].blank? }
  end

  def queue_items_with_valid_position
    params[:user][:queue_item].select { |_, v|v.include?(:position) }
  end

  def user_params
    params.require(:user).permit(:email, :full_name, :password)
  end
end

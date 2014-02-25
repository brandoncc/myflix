class UsersController < ApplicationController
  before_action :require_user, only: :show
  before_action :setup_invite, only: [:new, :create]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    charge = nil

    ActiveRecord::Base.transaction do
      charge = charge_new_customer if @user.save && params[:stripeToken]
      raise ActiveRecord::Rollback unless charge && charge.successful?
    end

    if @user.new_record?
      if charge && !charge.successful?
        flash.now[:danger] =  "#{charge.error_message} There was a problem creating your account. Please try again."
      else
        flash.now[:danger] =  'There was a problem creating your account. Please try again.'
      end

      render :new
    else
      handle_invite

      session[:user_id] = @user.id
      flash[:success] = 'Account created successfully, you have been logged in.'
      flash[:success] += " By the way, you are automatically following #{@user.leaders.first.full_name} because you accepted their invitation." unless @user.leaders.empty?
      redirect_to home_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :full_name, :password)
  end

  def handle_invite
    follow_and_lead_inviter(@user)
    expire_invite_token
    send_welcome_email(@user)
  end

  def follow_and_lead_inviter(new_user)
    if @invite && @invite.creator
      @invite.creator.follow(new_user)
      new_user.follow(@invite.creator)
    end
  end

  def expire_invite_token
    @invite.update_column(:token, nil) if @invite && !@invite.new_record?
  end

  def setup_invite
    if params[:user] && params[:user][:invite] && Invite.find_by(token: params[:user][:invite])
      @invite = Invite.find_by(token: params[:user][:invite])
    elsif params[:invite] && Invite.find_by(token: params[:invite])
      @invite = Invite.find_by(token: params[:invite])
    end

    @invite = Invite.new if @invite.nil?
  end

  def send_welcome_email(new_user)
    AppMailer.delay.welcome_email(new_user)
  end

  def charge_new_customer
    token = params[:stripeToken]

    StripeWrapper::Charge.create(amount: 999,
                                 card_token: token,
                                 description: user_params[:email])
  end
end

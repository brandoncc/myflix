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

    ActiveRecord::Base.transaction do
      @user.save!
      charge_new_customer
    end

    if !flash[:danger].present?
      handle_invite

      session[:user_id] = @user.id
      flash[:success] = 'Account created successfully, you have been logged in.'
      flash[:success] += " By the way, you are automatically following #{@user.leaders.first.full_name} because you accepted their invitation." unless @user.leaders.empty?
      redirect_to home_path
    else
      flash.now[:danger] += ' There was a problem creating your account. Please try again.'
      flash.now[:danger].strip!

      render :new
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
    # Set your secret key: remember to change this to your live secret key in production
    # See your keys here https://manage.stripe.com/account
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    # Get the credit card details submitted by the form
    token = params[:stripeToken]

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        :amount => 999, # amount in cents, again
        :currency => "usd",
        :card => token,
        :description => user_params[:email]
      )

      return true
    rescue Stripe::CardError => e
      flash[:danger] = e.message
      raise ActiveRecord::Rollback
    end
  end
end

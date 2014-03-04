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

    registration = SignUpService.new(@user).register(stripe_token: params[:stripeToken], invitation_token: params[:invitation_token])

    if registration.successful?
      session[:user_id] = @user.id
      flash[:success] = registration.message
      flash[:success] += " By the way, you are automatically following #{@user.leaders.first.full_name} because you accepted their invitation." unless @user.leaders.empty?
      redirect_to home_path
    else
      flash.now[:danger] =  registration.message
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :full_name, :password)
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

class InvitesController < ApplicationController
  before_action :require_user, only: [:new, :create]

  def new
    @invite = Invite.new
  end

  def create
    @invite = Invite.new(invite_params.merge!(creator: current_user))


    if User.find_by(email: @invite.email)
      flash[:danger] = 'It looks like your friend already has an account.'
      redirect_to new_invites_path
    elsif @invite.save
      AppMailer.send_invite_email(@invite).deliver
      flash[:success] = "#{@invite.name} has been invited.  Thanks for spreading the word!"
      redirect_to new_invites_path
    else
      flash[:danger] = 'There was a problem processing your invitation. Please try again.'
      render :new
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:name, :email, :message)
  end
end

class InvitationsController < ApplicationController 
  before_action :require_user, except: :accept_invitation
  def new
    @invitation = Invitation.new    
  end

  def create
    unless User.find_by(email: invitation_params[:email_invited]).nil?
      flash[:error] = 'User already exsit in Myflix'      
    else
      invitation = Invitation.new(invitation_params.merge!(user_id: current_user.id))
      if invitation.save
        AppMailer.delay.invitation(invitation)
        flash[:notice] = 'Invitation sent'        
      else
        flash[:error] = 'Email cannot be empty'  
      end
    end

    redirect_to :back
  end

  def accept_invitation
    @invitation = Invitation.find_by(token: params[:token])
    if @invitation.nil? 
      redirect_to invitation_expire_path
    else
      @user = User.new(email: @invitation.email_invited, name: @invitation.name)
    end
    
  end

  def invitation_params
    params.require(:invitation).permit(:email_invited, :name, :message)
  end
end
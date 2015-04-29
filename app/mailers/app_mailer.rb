class AppMailer < ActionMailer::Base 
  def welcome_letter(user)
    @user = user
    mail from: 'info@myflix.com', to: user.email, subject: 'welcome to myflix'
  end

  def forgot_password(user)
    @user = user
    mail from: 'info@myflix.com', to: user.email, subject: 'Resetting your password'
  end

  def invitation(invitation)
    @invitation = invitation                
    mail from: 'info@myflix.com', to: @invitation.email_invited, subject: "Invitation from #{@invitation.user.name}"
  end
end
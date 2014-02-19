class AppMailer < ActionMailer::Base
  default from: ENV['SMTP_FROM']

  def welcome_email(user)
    @user = user
    mail(to: "#{@user.full_name} <#{@user.email}>", subject: 'Welcome to myflix')
  end

  def send_password_reset_email(user)
    @user = user
    mail(to: "#{@user.full_name} <#{@user.email}>",
         subject: 'Password reset link for myflix')
  end

  def send_invite_email(invite)
    @invite = invite
    mail(to: "#{invite.email}",
         subject: "#{invite.creator.full_name} has invited you to join myflix")
  end
end

class AppMailer < ActionMailer::Base 
  def welcome_letter(user)
    @user = user
    mail from: 'info@myflix.com', to: user.email, subject: 'welcome to myflix'
  end
end
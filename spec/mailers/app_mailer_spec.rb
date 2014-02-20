require 'spec_helper'

describe AppMailer do
  describe '#welcome_email' do
    let(:user) { Fabricate(:user) }

    before do
      ActionMailer::Base.deliveries.clear
    end

    it 'sends an email' do
      email = AppMailer.delay.welcome_email(user)
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it 'sends the email to the proper user' do
      email = AppMailer.delay.welcome_email(user)
      expect(ActionMailer::Base.deliveries.last.to).to eq([user.email])
    end

    it 'sends the email from the proper address' do
      email = AppMailer.delay.welcome_email(user)
      expect(ActionMailer::Base.deliveries.last.from).to eq([ENV['SMTP_FROM']])
    end

    it 'sets the correct subject' do
      email = AppMailer.delay.welcome_email(user)
      expect(ActionMailer::Base.deliveries.last.subject).to eq('Welcome to myflix')
    end

    it 'sets the correct body' do
      email = AppMailer.delay.welcome_email(user)
      body_string = "Welcome to myflix, #{user.full_name}.\nWe are currently expanding our video library, so make sure you check out the library often!"
      expect(ActionMailer::Base.deliveries.last.body.to_s).to include(body_string)
    end
  end

  describe '#send_password_reset_email' do
    let(:user) { Fabricate(:user) }

    before do
      ActionMailer::Base.deliveries.clear
      user.generate_password_reset_token
    end

    it 'sends an email' do
      email = AppMailer.delay.send_password_reset_email(user)
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it 'sends the email to the proper user' do
      email = AppMailer.delay.send_password_reset_email(user)
      expect(ActionMailer::Base.deliveries.last.to).to eq([user.email])
    end

    it 'sends the email from the proper address' do
      email = AppMailer.delay.send_password_reset_email(user)
      expect(ActionMailer::Base.deliveries.last.from).to eq([ENV['SMTP_FROM']])
    end

    it 'sets the correct subject' do
      email = AppMailer.delay.send_password_reset_email(user)
      expect(ActionMailer::Base.deliveries.last.subject).to eq('Password reset link for myflix')
    end

    it 'sets the correct body' do
      email = AppMailer.delay.send_password_reset_email(user)
      body_string = "We received a password reset request for your account."
      expect(ActionMailer::Base.deliveries.last.body.to_s).to include(body_string)
    end
  end
end

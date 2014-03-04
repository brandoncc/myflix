require 'spec_helper'

describe SignUpService, :vcr do
  describe '#register' do
    context 'with valid user info and valid card info' do
      let(:subscription) { double('subscription', successful?: true) }
      let(:new_user) { Fabricate.build(:user) }
      before { expect(StripeWrapper::Subscription).to receive(:subscribe).and_return(subscription) }

      it 'charges payment card' do
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'creates user' do
        expect(new_user).to receive(:save)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'sends welcome email' do
        expect(AppMailer).to receive(:welcome_email)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'is successful' do
        expect(SignUpService.new(new_user).register(stripe_token: '123').successful?).to eq(true)
      end
    end

    context 'with valid user info and invalid or declined card info' do
      let(:subscription) { double('subscription', successful?: false, error_message: 'Your card was declined.') }
      let(:new_user) { Fabricate.build(:user) }
      before { expect(StripeWrapper::Subscription).to receive(:subscribe).and_return(subscription) }

      it 'does not create the user' do
        expect(new_user).not_to receive(:save)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'does not send welcome email' do
        expect(AppMailer).not_to receive(:welcome_email)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'has an error message' do
        expect(SignUpService.new(new_user).register(stripe_token: '123').message).to eq('Your card was declined.')
      end

      it 'is not successful' do
        expect(SignUpService.new(new_user).register(stripe_token: '123').successful?).to eq(false)
      end
    end

    context 'with invalid user info and valid card info' do
      let(:subscription) { double('subscription', successful?: true) }
      let(:new_user) { Fabricate.build(:user, password: nil) }
      before { expect(StripeWrapper::Subscription).not_to receive(:subscribe) }

      it 'does not create the user' do
        expect(new_user).not_to receive(:save)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'does not send welcome email' do
        expect(AppMailer).not_to receive(:welcome_email)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'does not attempt to charge the card' do
        expect(StripeWrapper::Subscription).not_to receive(:subscribe)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'has an error message' do
        expect(SignUpService.new(new_user).register(stripe_token: '123').message).to eq('There was a problem creating your account. Please try again.')
      end

      it 'is not successful' do
        expect(SignUpService.new(new_user).register(stripe_token: '123').successful?).to eq(false)
      end
    end

    context 'with invalid user info and invalid or declined card info' do
      let(:subscription) { double('subscription', successful?: false, error_message: 'Your card was declined.') }
      let(:new_user) { Fabricate.build(:user, password: nil) }
      before { expect(StripeWrapper::Subscription).not_to receive(:subscribe) }

      it 'does not create the user' do
        expect(new_user).not_to receive(:save)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'does not send welcome email' do
        expect(AppMailer).not_to receive(:welcome_email)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'does not attempt to charge the card' do
        expect(StripeWrapper::Subscription).not_to receive(:subscribe)
        SignUpService.new(new_user).register(stripe_token: '123')
      end

      it 'has an error message' do
        expect(SignUpService.new(new_user).register(stripe_token: '123').message).to eq('There was a problem creating your account. Please try again.')
      end

      it 'is not successful' do
        expect(SignUpService.new(new_user).register(stripe_token: '123').successful?).to eq(false)
      end
    end

    context 'with valid user info and card info with invitation token' do
      let(:subscription) { double('subscription', successful?: true) }
      let(:adam) { Fabricate(:user) }
      let(:new_user) { Fabricate.build(:user) }
      let(:invite) { Fabricate(:invite, creator: adam) }
      before { expect(StripeWrapper::Subscription).to receive(:subscribe).and_return(subscription) }

      it 'automatically follows inviter, if valid invite token is provided' do
        SignUpService.new(new_user).register(stripe_token: '123', invitation_token: invite.token)
        expect(new_user.leaders).to eq([adam])
      end

      it 'automatically leads inviter, if valid invite token is provided' do
        SignUpService.new(new_user).register(stripe_token: '123', invitation_token: invite.token)
        expect(new_user.followers).to eq([adam])
      end

      it 'does not automatically follow anybody if invalid invite token is provided' do
        SignUpService.new(new_user).register(stripe_token: '123', invitation_token: '123')
        expect(new_user.leaders).to eq([])
      end

      it 'expires invite token after invited user registers' do
        SignUpService.new(new_user).register(stripe_token: '123', invitation_token: invite.token)
        expect(invite.reload.token).to be_nil
      end
    end
  end
end

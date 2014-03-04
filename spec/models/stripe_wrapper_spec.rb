require 'spec_helper'

describe StripeWrapper::Charge, :vcr do
  context 'with valid card number' do
    let(:token) { stripe_token_for_valid_card }

    it 'charges the card successfully' do
      charge = StripeWrapper::Charge.create(amount: 999,
                                            card_token: token,
                                            description: 'test spec')

      expect(charge).to be_successful
    end
  end

  context 'with invalid card number' do
    let(:token) { stripe_token_for_invalid_card }

    it 'does not charge the card successfully' do
      charge = StripeWrapper::Charge.create(amount: 999,
                                            card_token: token,
                                            description: 'test spec')
      expect(charge).not_to be_successful
    end

    it 'has an error message' do
      charge = StripeWrapper::Charge.create(amount: 999,
                                            card_token: token,
                                            description: 'test spec')

      expect(charge.error_message).to eq('Your card was declined.')
    end
  end
end

describe 'StripeWrapper::Subscription#subscribe', :vcr do
  context 'user does not already subscribe' do
    context 'with valid card number' do
      let(:token) { stripe_token_for_valid_card }

      it 'assigns subscription id to the user' do
        adam = Fabricate(:user)
        subscription = StripeWrapper::Subscription.subscribe(adam, token)
        expect(adam.stripe_subscription_id).to be_present
      end

      it 'returns a successful status' do
        adam = Fabricate(:user)
        subscription = StripeWrapper::Subscription.subscribe(adam, token)
        expect(subscription.successful?).to eq(true)
      end
    end

    context 'with invalid card number' do
      let(:token) { stripe_token_for_invalid_card }

      it 'does not assign a subscription id to the user' do
        adam = Fabricate(:user)
        subscription = StripeWrapper::Subscription.subscribe(adam, token)
        expect(adam.stripe_subscription_id).to be_blank
      end

      it 'returns an error message' do
        adam = Fabricate(:user)
        subscription = StripeWrapper::Subscription.subscribe(adam, token)
        expect(subscription.error_message).to eq('Your card was declined.')
      end

      it 'returns an error status' do
        adam = Fabricate(:user)
        subscription = StripeWrapper::Subscription.subscribe(adam, token)
        expect(subscription.successful?).to eq(false)
      end
    end
  end

  context 'user already subscribes' do
    it 'returns an error message' do
      adam = Fabricate(:user, stripe_subscription_id: '123')
      subscription = StripeWrapper::Subscription.subscribe(adam, '123')
      expect(subscription.error_message).to eq('User already has an active subscription.')
    end

    it 'returns an error status' do
      adam = Fabricate(:user, stripe_subscription_id: '123')
      subscription = StripeWrapper::Subscription.subscribe(adam, '123')
      expect(subscription.successful?).to eq(false)
    end
  end
end

describe 'StripeWrapper::Customer.create', :vcr do
  context "user has not yet been added to stripe's customer database" do
    it 'assigns stripe customer id to the user' do
      adam = Fabricate(:user)
      StripeWrapper::Customer.create(adam)
      expect(adam.reload.stripe_customer_id).to be_present
    end

    it "returns the user's stripe customer instance" do
      adam = Fabricate(:user)
      stripe_customer = StripeWrapper::Customer.create(adam)
      expect(adam.reload.stripe_customer_id).to eq(stripe_customer.id)
    end
  end

  context "user has already been added to stripe's customer database" do
    it "does not assign a new stripe customer id to the user and it returns the user's stripe customer instance" do
      adam = Fabricate(:user)
      stripe_customer_first = StripeWrapper::Customer.create(adam)
      stripe_customer_second = StripeWrapper::Customer.create(adam)
      expect(adam.reload.stripe_customer_id).to eq(stripe_customer_first.id)
    end
  end
end

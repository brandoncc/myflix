require 'spec_helper'

describe StripeWrapper::Charge do
  before { StripeWrapper.set_api_key }

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

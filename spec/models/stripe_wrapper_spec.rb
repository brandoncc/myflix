require 'spec_helper'

describe StripeWrapper::Charge, :vcr do
  describe '#create' do
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
end

describe StripeWrapper::Subscription, :vcr do
  describe '#subscribe' do
    let(:adam) { Fabricate.build(:user) }
    context 'user does not already subscribe' do
      context 'with valid card number' do
        let(:token) { stripe_token_for_valid_card }

        it 'assigns subscription id to the user' do
          subscription = StripeWrapper::Subscription.subscribe(adam, token)
          expect(adam.stripe_subscription_id).to be_present
        end

        it 'returns a successful status' do
          subscription = StripeWrapper::Subscription.subscribe(adam, token)
          expect(subscription.successful?).to eq(true)
        end
      end

      context 'with invalid card number' do
        let(:token) { stripe_token_for_invalid_card }

        it 'does not assign a subscription id to the user' do
          subscription = StripeWrapper::Subscription.subscribe(adam, token)
          expect(adam.stripe_subscription_id).to be_blank
        end

        it 'returns an error message' do
          subscription = StripeWrapper::Subscription.subscribe(adam, token)
          expect(subscription.error_message).to eq('Your card was declined.')
        end

        it 'returns an error status' do
          subscription = StripeWrapper::Subscription.subscribe(adam, token)
          expect(subscription.successful?).to eq(false)
        end

        it 'deletes the stripe customer instance' do
          expect_any_instance_of(Stripe::Customer).to receive(:delete)
          subscription = StripeWrapper::Subscription.subscribe(adam, token)
        end
      end
    end

    context 'user already subscribes' do
      it 'returns an error message' do
        adam.stripe_subscription_id = '123'
        subscription = StripeWrapper::Subscription.subscribe(adam, '123')
        expect(subscription.error_message).to eq('User already has an active subscription.')
      end

      it 'returns an error status' do
        adam.stripe_subscription_id = '123'
        subscription = StripeWrapper::Subscription.subscribe(adam, '123')
        expect(subscription.successful?).to eq(false)
      end
    end
  end
end

describe StripeWrapper::Customer, :vcr do
  describe '#create' do
    context "user has not yet been added to stripe's customer database" do
      it 'assigns stripe customer id to the user' do
        adam = Fabricate.build(:user)
        StripeWrapper::Customer.create(adam)
        expect(adam.stripe_customer_id).to be_present
      end

      it "returns the user's stripe customer instance" do
        adam = Fabricate(:user)
        stripe_customer = StripeWrapper::Customer.create(adam)
        expect(adam.stripe_customer_id).to eq(stripe_customer.id)
      end
    end

    context "user has already been added to stripe's customer database" do
      it "does not assign a new stripe customer id to the user and it returns the user's stripe customer instance" do
        adam = Fabricate(:user)
        stripe_customer_first = StripeWrapper::Customer.create(adam)
        stripe_customer_second = StripeWrapper::Customer.create(adam)
        expect(adam.stripe_customer_id).to eq(stripe_customer_first.id)
      end
    end
  end
end


describe StripeWrapper::Invoice, :vcr do
  let(:adam) { Fabricate(:user) }

  describe '#retrieve' do
    context 'with valid invoice id' do
      it 'returns an invoice' do
        subcription_id = StripeWrapper::Subscription.subscribe(adam, stripe_token_for_valid_card)
        adam.save
        invoice_id = Stripe::Invoice.all(
          :customer => adam.stripe_customer_id,
          :count => 1
        )[:data].first[:id]
        expect(StripeWrapper::Invoice.retrieve(invoice_id)).to be_instance_of(Stripe::Invoice)
      end
    end

    context 'with invalid invoice id' do
      it 'returns nil' do
        expect(StripeWrapper::Invoice.retrieve('123')).to be_nil
      end
    end
  end
end

describe StripeWrapper::PaymentRecord, :vcr do
  describe '#create' do
    let(:adam) { Fabricate(:user) }

    after do
      Stripe::Customer.retrieve(adam.stripe_customer_id).delete if adam.stripe_customer_id.present?
      ActionMailer::Base.deliveries.clear
    end

    context 'payment not been processed before' do

      context 'payment is successful' do
        before do
          StripeWrapper::Subscription.subscribe(adam, stripe_token_for_valid_card)
          adam.locked = true
          adam.save
          invoice_id = Stripe::Invoice.all(
            :customer => adam.stripe_customer_id,
            :count => 1
          )[:data].first[:id]
          event = Stripe::Event.all.data.select{ |e| e.type == 'invoice.payment_succeeded' && e.data.object.id == invoice_id }.first
          StripeWrapper::PaymentRecord.create(event)
        end

        it 'creates payment' do
          expect(Payment.count).to eq(1)
        end

        it 'associates payment to user who paid' do
          expect(Payment.first.user).to eq(adam)
        end

        it 'marks the payment as successful' do
          expect(Payment.first).to be_successful
        end

        it 'emails the user a thank you letter' do
          expect(ActionMailer::Base.deliveries.last.to).to eq([adam.email])
        end

        it 'unlocks users account' do
          expect(adam.reload).not_to be_locked
        end
      end

      context 'payment is unsuccessful' do
        before do
          StripeWrapper::Subscription.subscribe(adam, stripe_token_for_valid_card)
          adam.save
          invoice_id = Stripe::Invoice.all(
            :customer => adam.stripe_customer_id,
            :count => 1
          )[:data].first[:id]
          event = Stripe::Event.all.data.select{ |e| e.type == 'invoice.payment_succeeded' && e.data.object.id == invoice_id }.first
          event.type = 'invoice.payment_failed'
          StripeWrapper::PaymentRecord.create(event)
        end

        it 'creates payment' do
          expect(Payment.count).to eq(1)
        end

        it 'associates payment to user who paid' do
          expect(adam.payments.count).to eq(1)
        end

        it 'marks the payment as unsuccessful' do
          expect(Payment.first).not_to be_successful
        end

        it 'emails the user a payment failure letter' do
          expect(ActionMailer::Base.deliveries.last.to).to eq([adam.email])
        end

        it 'locks users account' do
          expect(adam.reload).to be_locked
        end
      end
    end

    context 'payment has already been processed' do
      it 'does not create a second payment' do
        StripeWrapper::Subscription.subscribe(adam, stripe_token_for_valid_card)
        adam.save
        invoice_id = Stripe::Invoice.all(
          :customer => adam.stripe_customer_id,
          :count => 1
        )[:data].first[:id]
        event = Stripe::Event.all.data.select{ |e| e.type == 'invoice.payment_succeeded' && e.data.object.id == invoice_id }.first
        StripeWrapper::PaymentRecord.create(event)
        StripeWrapper::PaymentRecord.create(event)
        expect(adam.payments.count).to eq(1)
      end
    end
  end
end

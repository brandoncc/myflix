require 'spec_helper'

describe PaymentsController, :vcr do
  describe 'POST #create' do
    let(:adam) { Fabricate(:user) }
    context 'stripe event is invoice.payment_succeeded' do
      context 'with valid invoice object' do
        before do
          subcription_id = StripeWrapper::Subscription.subscribe(adam, stripe_token_for_valid_card)
          adam.save
          invoice_id = Stripe::Invoice.all(
            :customer => adam.stripe_customer_id,
            :count => 1
          )[:data].first[:id]
          post :create, type: 'invoice.payment_succeeded', data: { object: { id: invoice_id } }
        end

        it 'responds with 200' do
          expect(response.status).to eq(200)
        end

        it 'creates payment' do
          expect(Payment.count).to eq(1)
        end

        it 'associates payment to user who paid' do
          expect(adam.payments.count).to eq(1)
        end
      end

      context 'with invalid invoice' do
        it 'responds with 500' do
          post :create, type: 'invoice.payment_succeeded', data: { object: { id: 123 } }
          expect(response.status).to eq(500)
        end

        it 'does not create payment' do
          post :create, type: 'invoice.payment_succeeded', data: { object: { id: 123 } }
          expect(Payment.count).to eq(0)
        end
      end
    end

    context 'stripe event is not invoice.payment_succeeded' do
      it 'responds with 200' do
        post :create, type: 'invoice.created', data: { object: { id: 123 } }
        expect(response.status).to eq(200)
      end

      it 'does not create payment' do
        post :create, type: 'invoice.created', data: { object: { id: 123 } }
        expect(Payment.count).to eq(0)
      end
    end
  end
end

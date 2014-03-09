require 'spec_helper'

describe "Invoice Payment Successful" do
  before { Fabricate(:user, stripe_customer_id: 'cus_00000000000000') }
  def stub_event(fixture_id, status = 200)
    stub_request(:get, "https://api.stripe.com/v1/events/#{fixture_id}").
      to_return(status: status, body: File.read("spec/support/fixtures/#{fixture_id}.json"))
  end

  describe "invoice.payment_succeeded" do
    before do
      stub_event 'evt_invoice_payment_succeeded'
    end

    it "gets 200 response" do
      post '/stripe-events', id: 'evt_invoice_payment_succeeded'
      expect(response.code).to eq "200"
    end

    it 'creates the payment' do
      expect(StripeWrapper::PaymentRecord).to receive(:create)
      post '/stripe-events', id: 'evt_invoice_payment_succeeded'
    end

    it 'marks the payment as successful' do
      post '/stripe-events', id: 'evt_invoice_payment_succeeded'
      expect(Payment.first).to be_successful
    end
  end
end

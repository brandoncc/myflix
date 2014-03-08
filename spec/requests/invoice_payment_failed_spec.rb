require 'spec_helper'

describe "Invoice Payment Failed" do
  before { Fabricate(:user, stripe_customer_id: 'cus_00000000000000') }
  def stub_event(fixture_id, status = 200)
    stub_request(:get, "https://api.stripe.com/v1/events/#{fixture_id}").
      to_return(status: status, body: File.read("spec/support/fixtures/#{fixture_id}.json"))
  end

  describe "invoice.payment_failed" do
    before do
      stub_event 'evt_invoice_payment_failed'
    end

    it "gets 200 response" do
      post '/stripe-events', id: 'evt_invoice_payment_failed'
      expect(response.code).to eq "200"
    end

    it 'creates the payment' do
      expect(StripeWrapper::PaymentRecord).to receive(:create)
      post '/stripe-events', id: 'evt_invoice_payment_failed'
    end

    it 'marks the payment as unsuccessful' do
      post '/stripe-events', id: 'evt_invoice_payment_failed'
      expect(Payment.first).not_to be_successful
    end
  end
end

Stripe.api_key = ENV['STRIPE_SECRET_KEY']

StripeEvent.configure do |events|
  events.subscribe 'invoice.payment_succeeded' do |event|
    StripeWrapper::PaymentRecord.create(event)
  end
end

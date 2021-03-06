module StripeWrapper
  class Charge
    attr_reader :response, :error_message
    def initialize(options = {})
      @response      = options[:response]
      @error_message = options[:error_message]
    end

    def self.create(options = {})
      begin
        response = Stripe::Charge.create(
          amount: options[:amount],
          currency: "usd",
          card: options[:card_token],
          description: options[:description]
        )
        new(response: response)
      rescue Stripe::CardError => e
        new(error_message: e.message)
      end
    end

    def successful?
      response.present?
    end
  end

  class Subscription
    attr_reader :status, :error_message

    def initialize(status, message = nil)
      @status = status
      @error_message = message
    end

    def self.subscribe(user, card_token)
      if user.stripe_subscription_id.blank?
        begin
          stripe_customer = StripeWrapper::Customer.create(user)

          if stripe_customer
            stripe_customer.card = card_token
            stripe_customer.save
            subscription_id = stripe_customer.subscriptions.create(plan: 'myflix_subscription').id
            user.stripe_subscription_id = subscription_id
            new(:success)
          else
            new(:failure, 'There was a problem creating your subscription. Please try again')
          end
        rescue Stripe::CardError => e
          stripe_customer.delete if stripe_customer
          user.stripe_customer_id = nil
          new(:failure, e.message)
        end
      else
        new(:failure, 'User already has an active subscription.')
      end
    end

    def successful?
      status == :success
    end
  end

  class Customer
    def self.create(user)
      if user.stripe_customer_id.blank?
        stripe_customer = Stripe::Customer.create(
          email: user.email
        )

        user.stripe_customer_id = stripe_customer.id
      else
        stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
      end

      stripe_customer
    end
  end

  class Invoice
    def self.retrieve(id)
      Stripe::Invoice.retrieve(id)
    rescue Stripe::InvalidRequestError
      nil
    end
  end

  class PaymentRecord
    def self.create(event)
      invoice = event.data.object
      user = User.find_by(stripe_customer_id: invoice.customer)

      unless Payment.where(charge_id: invoice.charge).any?
        if event.type == 'invoice.payment_succeeded'
          payment = user.payments.create(invoice_id: invoice.id, charge_id: invoice.charge, amount: invoice.total, successful: true)
          AppMailer.delay.successful_payment(user, payment)
          user.unlock!
        elsif event.type == 'invoice.payment_failed'
          payment = user.payments.create(invoice_id: invoice.id, charge_id: invoice.charge, amount: invoice.total, successful: false)
          AppMailer.delay.failed_payment(user, payment)
          user.lock!
        end
      end
    end
  end
end

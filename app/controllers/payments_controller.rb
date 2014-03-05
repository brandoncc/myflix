class PaymentsController < ApplicationController
  def create
    if params[:type] == 'invoice.payment_succeeded'
      invoice = StripeWrapper::Invoice.retrieve(params[:data][:object][:id])

      if invoice
        Payment.create(user: User.find_by(stripe_customer_id: invoice.customer), charge_id: invoice.charge, invoice_id: invoice.id, amount: invoice.total)
        render status: 200
      else
        render status: 500
      end
    else
      render status: 200
    end
  end
end

class Payment < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :charge_id, :invoice_id, :amount
end

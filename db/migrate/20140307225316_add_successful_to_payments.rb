class AddSuccessfulToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :successful, :boolean
  end
end

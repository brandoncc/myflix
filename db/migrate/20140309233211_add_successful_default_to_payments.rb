class AddSuccessfulDefaultToPayments < ActiveRecord::Migration
  def change
    change_column_default :payments, :successful, true
  end
end

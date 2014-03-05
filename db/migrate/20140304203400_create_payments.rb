class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.string :charge_id
      t.string :invoice_id
      t.integer :amount
      t.timestamps
    end
  end
end

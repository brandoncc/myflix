class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :user_id
      t.string :email_invited
      t.string :name
      t.string :message
      t.string :token
      t.timestamps
    end
  end
end

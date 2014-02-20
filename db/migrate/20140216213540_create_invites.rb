class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :user_id
      t.string :email
      t.string :token

      t.timestamps
    end
  end
end

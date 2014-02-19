class AddNameAndMessageToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :name, :string
    add_column :invites, :message, :text
  end
end

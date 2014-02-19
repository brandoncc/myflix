class Invite < ActiveRecord::Base
  include Tokenable

  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  validates_presence_of :email, :name, :message
end

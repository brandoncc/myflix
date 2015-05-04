class Invitation < ActiveRecord::Base 
  include Tokenable
  belongs_to :user
  validates :email_invited, presence: true, on: :create  
  
  private
  def self.expire_token(email)
    Invitation.where(email_invited: email).each do |invitation|
      invitation.token = nil
      invitation.save
    end
  end
end
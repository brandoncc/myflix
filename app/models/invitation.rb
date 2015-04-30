class Invitation < ActiveRecord::Base 
  belongs_to :user
  validates :email_invited, presence: true, on: :create  

  before_create :generate_token

  private
  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end


  def self.expire_token(email)
    Invitation.where(email_invited: email).each do |invitation|
      invitation.token = nil
      invitation.save
    end
  end
end
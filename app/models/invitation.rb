class Invitation < ActiveRecord::Base 
  belongs_to :user
  validates :email_invited, presence: true, on: :create  

  before_create :generate_token

  private
  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end
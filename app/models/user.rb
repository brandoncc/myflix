class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true
  validates_presence_of :full_name

  has_secure_password validations: false
  validates_presence_of :password
end

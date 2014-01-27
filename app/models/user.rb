class User < ActiveRecord::Base
  has_many :reviews, -> { order(created_at: :desc) }

  validates :email, presence: true, uniqueness: true
  validates_presence_of :full_name

  has_secure_password validations: false
  validates_presence_of :password
end

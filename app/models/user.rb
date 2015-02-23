class User < ActiveRecord::Base
  has_secure_password validation: false
  has_many :reviews  
  has_many :my_queue_videos, -> { order(:position)}
  validates :password, presence: true, on: :create, length: {minimum: 5}
  validates :email, presence: true, uniqueness: true,  on: :create
  
  def queue_size
    my_queue_videos.size    
  end  

  def queue_video?(video)    
    my_queue_videos.map(&:video).include?(video) 
  end
end
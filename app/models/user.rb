class User < ActiveRecord::Base
  has_secure_password validation: false
  has_many :reviews  
  has_many :my_queue_videos, -> { order(:position)}
  
  has_many :friendships, -> { order("created_at desc")}
  has_many :friends, through: :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :followers, :through => :inverse_friendships, :source => :user

  validates :password, presence: true, on: :create, length: {minimum: 5}
  validates :email, presence: true, uniqueness: true,  on: :create
  
  def queue_size
    my_queue_videos.size    
  end  

  def review_size
    reviews.size
  end

  def queue_video?(video)    
    my_queue_videos.map(&:video).include?(video) 
  end

  def normalize_position
    my_queue_videos.each_with_index do |video, index|
      video.update_attributes(position: index+1)
    end
  end

  def follower_size
    inverse_friendships.size
  end
end
class User < ActiveRecord::Base
  include Tokenable

  has_secure_password
  has_many :reviews  
  has_many :my_queue_videos, -> { order(:position)}
  
  has_many :friendships, -> { order("created_at desc")}
  has_many :friends, through: :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :followers, through: :inverse_friendships, source: :user
  has_many :invitations

  validates :password, length: {minimum: 5}, allow_nil: true
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

  def follows?(another_user)
    friendships.map(&:friend).include?(another_user)
  end

  def follow(another_user)
    Friendship.create(user_id: self.id, friend_id: another_user.id)
  end

  def can_follow?(another_user)
    !(self.follows?(another_user) || self == another_user)
  end

  def generate_reset_token
    self.reset_token = SecureRandom.urlsafe_base64    
    save    
  end
  
  def clear_reset_token
    self.reset_token = nil
    save
  end

  def handle_invitation(token_param)
    if token_param.present?
      invitation = Invitation.find_by(token: token_param)
      if invitation
        self.follow(invitation.user)  
        invitation.user.follow(self)          
        Invitation.expire_token(invitation.email_invited)
      end
    end
  end

# override to_pram
  def to_param
    token
  end  

  
end
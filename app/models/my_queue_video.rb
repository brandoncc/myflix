class MyQueueVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :user
  
  validates_numericality_of :position, {only_integer: true }  

  def self.normalize_position(current_user)
    current_user.my_queue_videos.each_with_index do |video, index|
      video.update_attributes(position: index+1)
    end
  end

  def rating
    # review = Review.where(user_id: user.id, video_id: video.id).first    
    review.rating if review

  end

  def rating=(new_rating)    
    # binding.pry
    
    if !new_rating.blank?
      # 
      if review
        # binding.pry
        review.update_column(:rating, new_rating)
      else
        new_review = Review.new(rating: new_rating, user: user, video: video)
        new_review.save(validate: false)
      end
    else      
      # require 'pry';binding.pry
       review.destroy if review
    end
    
  end


   
  private
  def review
    @review ||= Review.where(user_id: user.id, video_id: video.id).first
  end

end
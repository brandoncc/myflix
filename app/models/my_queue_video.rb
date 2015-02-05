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
    review.rating if review

  end

  def rating=(new_rating)    
    # binding.pry
    # if new_rating
    if review
      review.update_column(:rating, new_rating)
    else
      review = Review.new(rating: new_rating, user: user, video: video)
      review.save(validate: false)
    end
    # else
    #   review.destroy if review
    # end
    
  end


  private 
  def review
    @review ||= Review.where(user_id: user.id, video_id: video.id).first
  end
end
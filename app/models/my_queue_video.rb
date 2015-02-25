class MyQueueVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :user
  
  validates_numericality_of :position, {only_integer: true }  


  def rating    
    review.rating if review

  end

  def rating=(new_rating)        
    
    if !new_rating.blank?
      
      if review      
        review.update_column(:rating, new_rating)
      else
        new_review = Review.new(rating: new_rating, user: user, video: video)
        new_review.save(validate: false)
      end
    else            
       review.destroy if review
    end
    
  end


   
  private
  def review
    @review ||= Review.where(user_id: user.id, video_id: video.id).first
  end

end
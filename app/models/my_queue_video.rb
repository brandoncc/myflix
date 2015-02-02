class MyQueueVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :user
  
  validates_numericality_of :position, {only_integer: true }  

  def self.normalize_position(current_user)
    current_user.my_queue_videos.each_with_index do |video, index|
      video.update_attributes(position: index+1)
    end
  end
end
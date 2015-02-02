class MyQueueVideosController < ApplicationController 
  before_action :require_user
  def index
    # binding.pry
    @videos = current_user.my_queue_videos
  end

  def create
    item = MyQueueVideo.find_by(video_id: params[:video_id], user_id: current_user.id)
    video = Video.find(params[:video_id])
    newitem = MyQueueVideo.new( video_id: params[:video_id], user_id: current_user.id, position: current_user.queue_size + 1 ) if item.nil?
    if item.nil? && newitem.save
      redirect_to my_queue_path
    else
        redirect_to :back
    end
  end

  def destroy    
    queue_video = MyQueueVideo.find(params[:id])
    queue_video.destroy unless queue_video.nil? 
    redirect_to my_queue_path
  end

  def update_queue_videos
      # binding.pry
      begin         
        update_items        
      rescue ActiveRecord::RecordInvalid
        flash[:error] = "Update Video Queue Items failed!"          
        redirect_to my_queue_videos_path
        return
      end               

      MyQueueVideo.normalize_position(current_user)
      redirect_to my_queue_videos_path
  end

  private

  def update_items
    ActiveRecord::Base.transaction do
      params[:video_datas].each do |video_data|
        queue_video = MyQueueVideo.find(video_data[:id])            
        queue_video.update_attributes!(position: video_data[:position])                                         
      end  
    end
  end

end
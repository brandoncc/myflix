class Admin::VideosController < AdminsController 
  def new
    @video = Video.new     
  end


  def create
    @video = Video.new( video_params)    
    if @video.save 
      redirect_to videos_path
    else
      render :new
    end
  end

  private 
  def video_params    
    params.require(:video).permit(:title, :description, :small_cover, :large_cover, category_ids:[]) 
  end    
end
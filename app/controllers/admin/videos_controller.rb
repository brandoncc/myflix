class Admin::VideosController < AdminController
  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)

    if @video.save
      flash[:success] = "The video has been added."
      redirect_to new_admin_video_path
    else
      flash[:danger] = "There was a problem creating the video. Please try again."
      render :new
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :category_id, :large_cover, :small_cover, :small_cover_cache, :large_cover_cache)
  end
end

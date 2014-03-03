class VideosController < AuthenticatedController
  def index
    @categories = Category.all
  end

  def show
    @review = Review.new
    @video = Video.find(params[:id]).decorate
  end

  def search
    @videos = Video.search_by_title(params[:search_string])
  end
end

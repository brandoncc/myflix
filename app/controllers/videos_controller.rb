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

  def advanced_search
    if params[:commit]
      @results = Video.search(params[:search_text],
                              reviews: params[:search_reviews],
                              rating_from: params[:rating_from],
                              rating_to: params[:rating_to]).results

      @results = VideoSearchDecorator.decorate_collection(@results)
    end
  end
end

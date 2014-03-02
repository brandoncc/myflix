class VideoDecorator < Draper::Decorator
  delegate_all

  def rating
    if reviews_with_rating.any?
      "Rating: #{object.average_rating}/5.0"
    else
      "Rating: No ratings yet, #{h.link_to 'rate it now', '#reviews'}.".html_safe
    end
  end

  def reviews_with_rating
    object.reviews.select{ |review| review.rating }
  end
end

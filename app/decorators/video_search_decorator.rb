class VideoSearchDecorator
  attr_reader :object

  delegate :small_cover_url, :average_rating, :reviews, to: :object

  def initialize(object)
    @object = object
  end

  def self.decorate(object)
    new(object)
  end

  def self.decorate_collection(objects)
    VideoSearchDecoratorCollection.new(objects)
  end

  def title
    if object.try(:highlight) && object.highlight['title'].present?
      object.highlight['title'].first.html_safe
    else
      object.title
    end
  end

  def description
    if object.try(:highlight) && object.highlight['description'].present?
      object.highlight['description'].first.html_safe
    else
      object.description
    end
  end

  def first_review
    if object.try(:highlight) && object.highlight['reviews.body'].present?
      object.highlight['reviews.body'].first.html_safe
    elsif object.reviews && object.reviews.present?
      object.reviews.first.body
    else
      'There are currently no reviews.'
    end
  end
end

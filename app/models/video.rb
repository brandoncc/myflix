class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews, -> { order(created_at: :desc) }
  has_many :queue_items

  validates_presence_of :title, :description, :video_url

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name [Rails.application.engine_name, Rails.env].join('_')

  mount_uploader :small_cover, SmallCoverUploader
  mount_uploader :large_cover, LargeCoverUploader

  def self.search_by_title(title)
    return [] if title.blank?

    self.where('lower(title) LIKE :search_string', search_string: '%' + title.to_s.downcase + '%').
      order(created_at: :desc)
  end

  def average_rating
    (total_reviews_rating / reviews_count).round(1)
  end

  def self.search(query)
    search_definition =
      if query.present?
        {
          query: {
            multi_match: {
              query: query,
              fields: ['title', 'description'],
              operator: 'and'
            }
          }
        }
      else
        {
          query: {
            match_all: {}
          }
        }
      end

    __elasticsearch__.search(search_definition)
  end

  def as_indexed_json(options = {})
    as_json(only: [:title, :description])
  end

  private

  def total_reviews_rating
    self.reviews.inject(0) { |sum, review| sum + review.rating }.to_f
  end

  def reviews_count
    self.reviews.count
  end
end

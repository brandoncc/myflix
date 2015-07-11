class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews, -> { order(created_at: :desc) }
  has_many :queue_items

  validates_presence_of :title, :description, :video_url

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name [Rails.application.engine_name, Rails.env].join('_')

  settings do
    mappings do
      indexes :average_rating, type: 'float'
    end
  end

  mount_uploader :small_cover, SmallCoverUploader
  mount_uploader :large_cover, LargeCoverUploader

  def self.search_by_title(title)
    return [] if title.blank?

    self.where('lower(title) LIKE :search_string', search_string: '%' + title.to_s.downcase + '%').
      order(created_at: :desc)
  end

  def average_rating
    if reviews_count > 0
      (total_reviews_rating.to_f / reviews_count).round(1)
    else
      nil
    end
  end

  def self.search(query, options = {})
    search_definition =
      if query.present?
        {
          query: {
            multi_match: {
              query: query,
              fields: ['title^100', 'description^50'],
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

    if options[:reviews] && options[:reviews]
      search_definition[:query][:multi_match][:fields] << 'reviews.body'
    end

    if options[:rating_from].present? || options[:rating_to].present?
      search_definition[:filter] = {
          range: {
            average_rating: {
              gte: (options[:rating_from] if options[:rating_from].present?),
              lte: (options[:rating_to] if options[:rating_to].present?)
          }
        }
      }

      search_definition[:sort] = [ average_rating: { order: :desc } ]
    end

    __elasticsearch__.search(search_definition)
  end

  def as_indexed_json(options = {})
    as_json(
      include: {
        reviews: { only: :body }
      },
      methods: [:average_rating],
      only: [:title, :description, :average_rating]
    )
  end

  private

  def total_reviews_rating
    self.reviews.inject(0) { |sum, review| sum + review.rating }.to_f
  end

  def reviews_count
    self.reviews.count
  end
end

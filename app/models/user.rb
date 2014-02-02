class User < ActiveRecord::Base
  has_many :reviews, -> { order(created_at: :desc) }
  has_many :queue_items, -> { order(position: :asc, created_at: :desc) }

  validates :email, presence: true, uniqueness: true
  validates_presence_of :full_name

  has_secure_password validations: false
  validates_presence_of :password

  def reorder_queue_items(items)
    transaction_was_successful = true

    ActiveRecord::Base.transaction do
      items.each do |id, parameters|
        queue_item = QueueItem.find(id)
        if parameters[:position] =~ /\A\d+\z/ && queue_item.user == self
          queue_item.position = parameters[:position]
          queue_item.save
        else
          transaction_was_successful = false
          raise ActiveRecord::Rollback
        end
      end
      sort_queue_items_by_position
    end

    transaction_was_successful
  end

  def update_queue_item_ratings(items)
    transaction_was_successful = true

    ActiveRecord::Base.transaction do
      items.each do |id, parameters|
        if Review.valid_ratings.include?(parameters[:rating].to_i)
          queue_item = QueueItem.find(id)
          review = Review.find_by_creator_and_video(self, queue_item.video)
          if review
            review.rating = parameters[:rating]
          else
            review = Review.new(creator: self, video: queue_item.video, rating: parameters[:rating])
          end

          if !review.save(validate: false)
            transaction_was_successful = false
            raise ActiveRecord::Rollback
          end
        else
          transaction_was_successful = false
          raise ActiveRecord::Rollback
        end
      end
    end

    transaction_was_successful
  end

  private

  def sort_queue_items_by_position
    break_position_ties
    fill_queue_item_position_gaps
  end

  def break_position_ties
    while self.queue_items.reload.map(&:position).uniq.count != self.queue_items.count
      items_to_sort = self.queue_items.map { |queue_item| [queue_item.id, queue_item.position] }

      items_to_sort.each_with_index do |item, index|
        if index < items_to_sort.count - 1
          if items_to_sort[index][1] >= items_to_sort[index + 1][1]
            next_queue_item = QueueItem.find(items_to_sort[index + 1][0])
            next_queue_item.position += 1
            next_queue_item.save
          end
        end
      end
    end
  end

  def fill_queue_item_position_gaps
    self.queue_items.reload.each_with_index do |item, index|
      if item.position != index + 1
        item.position = index + 1
        item.save
      end
    end
  end
end

class FixMyQueueVideoColumnName < ActiveRecord::Migration
  def change
    rename_column :my_queue_videos, :index, :position
  end
end

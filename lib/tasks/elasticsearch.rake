require 'elasticsearch/rails/tasks/import'

def say_with_time(words)
  ActiveRecord::Migration.say_with_time("#{words}...") do
    yield
  end
end

namespace :elasticsearch do
  desc "Index videos"
  task index: :environment do
    say_with_time "creating new index and importing data to Elasticsearch" do
      Video.__elasticsearch__.create_index! force: true
      Video.import
      Video.__elasticsearch__.refresh_index!
    end
  end
end

require 'spec_helper'

describe Category do
  it { should have_many(:videos) }
  it { should validate_presence_of(:name) }

  describe '#recent_videos' do
    it 'returns all videos if less than six exist in this category' do
      drama = Category.create(name: 'drama')
      3.times { Fabricate(:video, category_id: drama.id) }
      expect(drama.recent_videos.count).to eq(3)
    end

    it 'returns all videos if exactly six exist in this category' do
      drama = Category.create(name: 'drama')
      6.times { Fabricate(:video, category_id: drama.id) }
      expect(drama.recent_videos.count).to eq(6)
    end

    it 'returns at most six videos if more than six exist' do
      drama = Category.create(name: 'drama')
      8.times { Fabricate(:video, category_id: drama.id) }
      expect(drama.recent_videos.count).to eq(6)
    end

    it 'returns videos in descending order, based on created_at' do
      drama = Category.create(name: 'drama')
      sons_of_anarchy = Fabricate(:video, created_at: 2.days.ago, category_id: drama.id)
      dexter = Fabricate(:video, created_at: 1.days.ago, category_id: drama.id)
      breaking_bad = Fabricate(:video, category_id: drama.id)
      expect(drama.recent_videos).to eq([breaking_bad, dexter, sons_of_anarchy])
    end

    it 'returns an empty array if the category has no videos' do
      drama = Category.create(name: 'drama')
      expect(drama.recent_videos).to eq ([])
    end
  end
end

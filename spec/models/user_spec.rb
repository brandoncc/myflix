require 'spec_helper'

describe User do
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
  it { should validate_presence_of :full_name }
  it { should have_secure_password }
  it { should validate_presence_of :password }
  it { should have_many :reviews }
  it { should have_many :queue_items }

  it 'retrieves reviews in reverse cronological order' do
    user = Fabricate(:user)
    review1 = Fabricate(:review, creator: user, created_at: 1.day.ago)
    review2 = Fabricate(:review, creator: user)
    expect(user.reviews).to eq([review2, review1])
  end

  it 'retrieves queued_items in ascending order sorted by position' do
    user = Fabricate(:user)
    queue_item1 = Fabricate(:queue_item, user: user, position: 2)
    queue_item2 = Fabricate(:queue_item, user: user, position: 1)
    expect(user.queue_items).to eq([queue_item2, queue_item1])
  end

  describe '#queued_videos' do
    it 'returns an empty array if no videos are queued' do
      user = Fabricate(:user)
      expect(user.queued_videos).to eq([])
    end

    it 'returns an array of all videos queued by current user' do
      user = Fabricate(:user)
      first_video = Fabricate(:video)
      second_video = Fabricate(:video)
      user.queue_items.create(video: first_video, position: 1)
      user.queue_items.create(video: second_video, position: 2)
      expect(user.queued_videos).to match_array([first_video, second_video])
    end
  end
end

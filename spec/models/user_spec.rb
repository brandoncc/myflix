require 'rails_helper'
  
describe User do 
  it { should have_many(:my_queue_videos).order(:position)}
  it { should have_many(:friendships)}
  it { should have_many(:friends).through(:friendships) }  
  it { should have_many(:invitations)}

  it_behaves_like 'tokenable' do
    let(:object) { Fabricate(:user )}
  end

  describe '#queue_video' do
    it 'return true when the user has not queued the video' do
      user = Fabricate(:user)
      video = Fabricate(:video)
      user.queue_video?(video).should_not be  true
    end

    it 'return true when the user has queued the video' do
      user = Fabricate(:user)
      video = Fabricate(:video)
      queue = Fabricate(:my_queue_video, user: user, video: video )

      user.queue_video?(video).should be true
    end
  end

  describe '#follows' do

    it 'should return true if the user is following another user' do
      user = Fabricate(:user)
      bob = Fabricate(:user)
      friendship = Fabricate(:friendship,  follower: user, friend: bob)
      expect(user.follows?(bob)).to eq(true)
    end
    it 'should return false if the user is not following another user' do
      user = Fabricate(:user)
      bob = Fabricate(:user)
      expect(user.follows?(bob)).to eq(false)
    end
  end
end
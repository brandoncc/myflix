require 'rails_helper'
  
describe User do 
  it { should have_many(:my_queue_videos).order(:position)}

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

end
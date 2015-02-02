require 'rails_helper'

describe MyQueueVideosController do 
  let!(:user) { Fabricate(:user)}
  describe 'GET Index' do
    it "should set the correct video_queues attribute" do      
      login(user)
      2.times do
        video = Fabricate(:video)
        vq = Fabricate(:my_queue_video, video: video, user: user )
      end
      get :index
      assigns(:videos).size.should == 2      
    end

    it "should render the index template when login" do      
      login(user)
      get :index
      response.should render_template :index
    end

    it "should redirect to root path when not logged in" do
      get :index
      response.should redirect_to root_path
    end
  end

  describe 'POST Create' do
    it "should redirect to root path if not logged in" do
      post :create
      response.should redirect_to root_path
    end

    it "should create the my_queue_video object successfully when logged in" do      
      login(user)
      2.times do
        video = Fabricate(:video)        
      end
      post :create, video_id: 1
      expect(MyQueueVideo.count).to eq(1)
    end
  end

  describe 'DELETE Destroy' do
    it 'should delete the queue video when logged in' do
      login(user)
      2.times do
        video = Fabricate(:video)
        vq = Fabricate(:my_queue_video, video_id: video.id, user_id: user.id )
      end
      delete :destroy, id: 1
      expect(MyQueueVideo.count).to eq(1)
    end

    it 'should redirect to root path when not logged in' do
      delete :destroy, id: 1
      response.should redirect_to root_path
    end
  end

  describe 'POST Update_queue_videos' do
    let!(:user) { Fabricate(:user)}
    let(:video1) { Fabricate(:video)}
    let(:video2) { Fabricate(:video)}
    let(:q1) { Fabricate(:my_queue_video, user: user, video: video1, position: 1)}
    let(:q2) { Fabricate(:my_queue_video, user: user, video: video2, position: 2)}
    context 'with valid inputs' do
      before do
        login(user)    
      end      
      it 'should redirect to queue path after update succesfully' do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 2}, {id: q2.id, position: 1} ]
        expect(response).to redirect_to my_queue_videos_path
      end  
      it 'should update the index order of the videos correctly' do        
        post :update_queue_videos, video_datas: [{id: q1.id, position: 2}, {id: q2.id, position: 1} ]
        expect(user.my_queue_videos.map(&:id)).to eq([q2.id, q1.id])
      end

      it 'normalize the position number' do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3}, {id: q2.id, position: 2} ]
        expect(user.my_queue_videos.map(&:position)).to eq([1, 2])
      end
    end

    context 'with invalid inputs' do
      before do
        login(user)        
      end
      it "should not update the position when input are not valid" do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 2.1}, {id: q2.id, position: 1} ]
        expect(user.my_queue_videos).to eq([q1, q2])
      end
      it "should rollback the first transaction when the second input is invalid" do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3}, {id: q2.id, position: 1.1} ]
        expect(user.my_queue_videos.map(&:id)).to eq([q1.id, q2.id])
      end
      it 'should redirect to my_queue_path when input are not valid' do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 2.1}, {id: q2.id, position: 1} ]
        expect(response).to redirect_to my_queue_videos_path
      end

      it 'should have flash error when update failed' do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 2.1}, {id: q2.id, position: 1} ]
        expect(flash[:error]).to be_present
      end
    end
    context 'update as a non-owner' do
      before {login(Fabricate(:user))}
      it 'should not change the queue videos when user is not the owner of the videos' do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3}, {id: q2.id, position: 1} ]
        expect(user.my_queue_videos).to eq([q1, q2])
      end
    end

  end
end
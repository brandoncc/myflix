require 'rails_helper'

describe MyQueueVideosController do 
  before do
    login_current_user
  end
  describe 'GET Index' do
    it "should set the correct video_queues attribute" do      
      # login(user)
      2.times do
        video = Fabricate(:video)
        vq = Fabricate(:my_queue_video, video: video, user: current_user )
      end
      get :index
      assigns(:videos).size.should == 2      
    end

    it "should render the index template when login" do      
      # login(user)
      get :index
      response.should render_template :index
    end

    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { get :index }
      end
    end
  end

  describe 'POST Create' do

    it "should create the my_queue_video object successfully when logged in" do      
      # login(user)
      2.times do
        video = Fabricate(:video)        
      end
      post :create, video_id: 1
      expect(MyQueueVideo.count).to eq(1)
    end

    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { post :create }
      end
    end

  end

  describe 'DELETE Destroy' do
    it 'should delete the queue video when logged in' do
      # login(user)
      2.times do
        video = Fabricate(:video)
        vq = Fabricate(:my_queue_video, video: video, user: current_user, position: 3 )
      end
      delete :destroy, id: 1
      expect(MyQueueVideo.count).to eq(1)
    end

    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { delete :destroy, id: 1 }
      end
    end

    it 'should normalize the position after delete' do
      # login(user)
      2.times do
        video = Fabricate(:video)
        vq = Fabricate(:my_queue_video, video: video, user: current_user, position: 3 )
      end
      # require 'pry'; binding.pry
      delete :destroy, id: 1

      expect(current_user.my_queue_videos.map(&:position)).to eq([1])
    end
  end

  describe 'POST Update_queue_videos' do    
    
    context 'with valid inputs' do
      let(:video1) { Fabricate(:video)}
      let(:video2) { Fabricate(:video)}
      let(:q1) { Fabricate(:my_queue_video, user: current_user, video: video1, position: 1)}
      let(:q2) { Fabricate(:my_queue_video, user: current_user, video: video2, position: 2)}
      
      # before do
        # login(user)    
      # end      
      it 'should redirect to queue path after update succesfully' do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 2, rating: 3}, {id: q2.id, position: 1, rating: 3} ]
        expect(response).to redirect_to my_queue_videos_path
      end  
      it 'should update the index order of the videos correctly' do        
        post :update_queue_videos, video_datas: [{id: q1.id, position: 2, rating: 3}, {id: q2.id, position: 1, rating: 3 } ]
        expect(current_user.my_queue_videos.map(&:id)).to eq([q2.id, q1.id])
      end

      it 'normalize the position number' do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3, rating: 3}, {id: q2.id, position: 2, rating: 3 } ]
        expect(current_user.my_queue_videos.map(&:position)).to eq([1, 2])
      end

      it 'should create new review of the video if no review exsit' do 
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3, rating: 3}, {id: q2.id, position: 2, rating: 3 } ]
        expect(current_user.reviews.map(&:rating)).to eq([3, 3 ])
      end

      it 'should update the review if review exsit' do
        review = Fabricate(:review, user: current_user, video: video1, rating: 5)
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3, rating: 2}]
        expect(current_user.my_queue_videos.map(&:rating)).to eq([2 ])
      end

      it 'should empty the review if blank is selected' do
        review = Fabricate(:review, user: current_user, video: video1, rating: 5)
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3, rating: nil}]
        
        expect(current_user.my_queue_videos.map(&:rating)).to eq([nil])
      end
    end


    context 'with invalid inputs' do
      let(:video1) { Fabricate(:video)}
      let(:video2) { Fabricate(:video)}
      let(:q1) { Fabricate(:my_queue_video, user: current_user, video: video1, position: 1)}
      let(:q2) { Fabricate(:my_queue_video, user: current_user, video: video2, position: 2)}
      before do
        # login(user)        
      end
      it "should not update the position when input are not valid" do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 2.1}, {id: q2.id, position: 1} ]
        expect(current_user.my_queue_videos).to eq([q1, q2])
      end
      it "should rollback the first transaction when the second input is invalid" do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3}, {id: q2.id, position: 1.1} ]
        expect(current_user.my_queue_videos.map(&:id)).to eq([q1.id, q2.id])
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
      let(:new_user) { Fabricate(:user)}
      let(:video1) { Fabricate(:video)}
      let(:video2) { Fabricate(:video)}
      let(:q1) { Fabricate(:my_queue_video, user: new_user, video: video1, position: 1)}
      let(:q2) { Fabricate(:my_queue_video, user: new_user, video: video2, position: 2)}
      # before {login(Fabricate(:user))}
      it 'should not change the queue videos when user is not the owner of the videos' do
        post :update_queue_videos, video_datas: [{id: q1.id, position: 3}, {id: q2.id, position: 1} ]
        expect(new_user.my_queue_videos).to eq([q1, q2])
      end
    end



  end
end
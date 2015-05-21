require 'rails_helper'

describe Admin::VideosController do
  describe 'GET New' do
    
    context 'login as non-admin' do
      it_behaves_like 'require_admin' do
        let(:action) { get :new }
      end
    end

    context 'login as admin' do
      before { login_admin }
      it 'sets the instance variable correctly' do
        get :new
        expect(assigns(:video)).to be_instance_of(Video)
      end
    end

  end

  describe 'POST Create' do
    before { login_admin }
    context 'with insufficient input' do
      it 'does not create the video' do
        post :create, video: {title: '', description: 'dd', category_ids: [] }
        expect(Video.count).to eq(0)     
      end 
    end

    context 'with valid input' do
      let(:category) {Fabricate(:category)}
      it 'creates the video' do        
        post :create, video: {title: 'starwar', description: 'very nice movie', category_ids: [category.id]}
        expect(Video.count).to eq(1)        
      end      

      it 'creates the videocategories' do
        
        post :create, video: {title: 'starwar', description: 'very nice movie', category_ids: [category.id]}
        expect(VideoCategory.count).to eq(1)
      end
      it 'redirect to videos path' do
        post :create, video: {title: 'starwar', description: 'very nice movie', category_ids: [category.id]}
        expect(response).to redirect_to videos_path
      end
    end

    context 'login as non-admin' do
      it_behaves_like 'require_admin' do
        let(:action) { get :new }
      end
    end

  end
end
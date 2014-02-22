require 'spec_helper'

describe Admin::VideosController do
  describe 'GET #new' do
    it_behaves_like 'an unauthenticated user' do
      let(:action) { get :new }
    end

    it_behaves_like 'a non-admin user' do
      let(:action) { get :new }
    end

    context 'logged in as an admin' do
      it 'sets up @video' do
        adam = Fabricate(:admin)
        set_current_user(adam)
        get :new
        expect(assigns(:video)).to be_a_new(Video)
      end
    end
  end

  describe 'POST #create' do
    it_behaves_like 'an unauthenticated user' do
      let(:action) { post :create }
    end

    it_behaves_like 'a non-admin user' do
      let(:action) { post :create }
    end

    context 'logged in as an admin' do
      context 'with valid params' do
        let(:video_upload) {
          {
            title: Faker::Lorem.words(2).join(' '),
            category_id: Category.create(name: 'Comedy').id,
            description: Faker::Lorem.paragraphs(2).join(' '),
            large_cover: Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/uploads/30_rock_large.jpg"),
            small_cover: Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/uploads/30_rock_small.jpg"),
            video_url: 'http://google.com'
          }
        }

        it 'redirects to the admin new video path' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(response).to redirect_to(new_admin_video_path)
        end

        it 'creates a new video' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(Video.count).to eq(1)
        end

        it 'shows a success message' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(flash[:success]).to be_present
        end
      end

      context 'with invalid params' do
        let(:video_upload) {
          {
            title: Faker::Lorem.words(2).join(' '),
            category_id: Category.create(name: 'Comedy').id,
            large_cover: Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/uploads/30_rock_large.jpg"),
            small_cover: Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/uploads/30_rock_small.jpg")
          }
        }

        it 'renders new form' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(response).to render_template(:new)
        end

        it 'does not create a video' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(Video.count).to eq(0)
        end

        it 'shows an error message' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(flash[:danger]).to be_present
        end

        it 'sets @video' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(assigns(:video)).to be_present
        end

        it 'sets @video.small_cover_cache' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(assigns(:video).small_cover_cache).to be_present
        end

        it 'sets @video.large_cover_cache' do
          adam = Fabricate(:admin)
          set_current_user(adam)
          post :create, video: video_upload
          expect(assigns(:video).large_cover_cache).to be_present
        end
      end
    end
  end
end

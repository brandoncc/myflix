require 'spec_helper'

describe Admin::VideosController do
  describe '#new' do
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

  describe '#create' do
    it_behaves_like 'an unauthenticated user' do
      let(:action) { get :new }
    end

    it_behaves_like 'a non-admin user' do
      let(:action) { get :new }
    end

    context 'logged in as an admin'
  end
end

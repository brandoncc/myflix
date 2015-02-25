require 'rails_helper'

describe VideosController do
  before do
    login_current_user
  end
  describe 'GET Index' do    
    
    it 'sets the @category attribute when logged in'  do
      sifi = Category.create(name: 'sifi')
      et = Video.create(title: 'et', description: 'lalalalala', categories: [sifi])              
      get :index
      assigns(:categories).should == [sifi]
    end
    it 'render index template when signed in' do
      get :index
      response.should render_template :index
    end  
    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { get :index }
      end
    end    
  end  

  describe 'GET Show' do  
    let!(:et) { Fabricate(:video) } # eager loading by using !
    
    it 'should set the @video attribute' do              
      get :show, id: '1'
      assigns(:video).should == et
    end
    it 'should render show template when logged in' do          
      get :show, id: '1'
      response.should render_template :show      
    end  
  
    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { get :show, id: '1' }
      end
    end        
  end

  describe 'GET Search' do
    let!(:et) { Fabricate(:video) }
  
    it 'should set the results attribute correctly' do             
      get :search, query: 'e'
      assigns(:results).should == [et]
    end
    it 'should render the search template when logged in' do       
      get :search, query: 'e'
      response.should render_template :search
    end
  
    context 'not logged in' do
      it_behaves_like 'require_sign_in' do
        let(:action) { get :search, query: 'e' }
      end
    end        
  end
end
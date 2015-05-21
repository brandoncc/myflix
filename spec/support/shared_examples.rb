shared_examples 'require_sign_in' do 
  it 'redirect to the front page' do
    clear_current_session
    action
    response.should redirect_to root_path
  end
end

shared_examples 'require_admin' do
  it 'redirect to the root path' do
    clear_current_session
    login_current_user
    action
    response.should redirect_to root_path
  end
end

shared_examples 'tokenable' do
  it 'generates random token when object is created' do
    expect(object.token).to be_present
  end
end
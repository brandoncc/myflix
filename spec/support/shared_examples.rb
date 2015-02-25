shared_examples 'require_sign_in' do 
  it 'redirect to the front page' do
    clear_current_session
    action
    response.should redirect_to root_path
  end
end
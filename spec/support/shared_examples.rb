shared_examples 'an unauthenticated user' do
  it 'redirects to the sign in page' do
    clear_current_user
    action
    expect(response).to redirect_to sign_in_path
  end

  it 'sets warning message' do
    clear_current_user
    action
    expect(flash[:info]).not_to be_blank
  end
end

shared_examples 'tokenable' do
  it 'creates a token when the instance is created' do
    expect(object.token).to be_present
  end
end

shared_examples 'a non-admin user' do
  it 'redirects to the home page' do
    adam = Fabricate(:user)
    set_current_user(adam)
    action
    expect(response).to redirect_to(home_path)
  end

  it 'sets error message' do
    adam = Fabricate(:user)
    set_current_user(adam)
    action
    expect(flash[:danger]).to be_present
  end
end

shared_examples 'the wrong user' do
  it 'redirects to the home page' do
    adam = Fabricate(:user)
    set_current_user(adam)
    action
    expect(response).to redirect_to(home_path)
  end

  it 'sets error message' do
    adam = Fabricate(:user)
    set_current_user(adam)
    action
    expect(flash[:danger]).to be_present
  end
end

require 'rails_helper'

feature 'user sign in' do
  
  scenario 'sign in with correct credentials' do
    user = Fabricate(:user)
    sign_in(user)
    # save_and_open_page
    expect(page).to have_content "Welcome, you have logged in "
  end

  scenario 'sign in with invalid credentials' do
    visit login_path
    fill_in 'email', with: 'test@test.com'
    fill_in 'password', with: '1111'
    click_button 'Log in'
    expect(page).to have_content "Username or password does not match."
  end
end
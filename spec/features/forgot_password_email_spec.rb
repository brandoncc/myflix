require 'rails_helper'

feature 'User reset the password' do
  scenario 'user can rest the password successfully' do
    alice = Fabricate(:user, password: 'old_password')
    visit login_path
    click_link 'Forgot password?'
    fill_in 'Email Address', with: alice.email
    click_button 'Send email'

    open_email(alice.email)
    current_email.click_link 'Resetting password'

    fill_in 'New password', with: 'new_password'
    click_button 'Reset password'

    fill_in 'Email Address', with: alice.email
    fill_in 'Password', with: 'new_password'
    click_button 'Log in'
    expect(page).to have_content('Welcome')
  end
end

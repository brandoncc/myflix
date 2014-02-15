require 'spec_helper'

feature 'Reset password' do
  scenario 'User can reset password using form and link from email' do
    adam = Fabricate(:user)

    visit sign_in_path
    click_on 'Forgot password'
    fill_in 'Email address', with: adam.email
    click_on 'Send Email'
    open_email(adam.email)
    current_email.click_link('click here')
    fill_in 'password', with: "#{adam.password}changed"
    click_on 'Reset Password'
    fill_in 'email', with: adam.email
    fill_in 'password', with: "#{adam.password}changed"
    click_on 'Sign in'
    expect(page).to have_content('logged in successfully')
  end
end

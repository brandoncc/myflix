def sign_in(a_user=nil)
  user = a_user || Fabricate(:user)
  visit login_path
  fill_in 'email', with: user.email
  fill_in 'password', with: user.password
  click_button 'Log in'
end

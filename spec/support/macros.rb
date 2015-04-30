def sign_in(a_user=nil)
  user = a_user || Fabricate(:user)
  visit login_path
  fill_in 'email', with: user.email
  fill_in 'password', with: user.password
  click_button 'Log in'
end

def sign_out
  visit logout_path
end

def visit_video_page(video)
  find("a[href='/videos/#{video.id}']").click  
end

def visit_user_page(user)
  find("a[href='/users/#{user.token}']").click
end
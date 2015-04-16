require 'rails_helper'

feature 'current user follow un follow another user' do   

  scenario 'user follow unfollow another user' do
    sign_in 
    v1 = Fabricate(:video, title: 'starwar')
    c = Category.create(name: 'comedy')
    v1.categories << c

    user2 = Fabricate(:user)
    Fabricate(:review, video: v1, user: user2)    

    visit home_path
    visit_video_page(v1)
    expect(page).to have_content('starwar')
    
    visit_user_page(user2)
    expect(page).to have_content('Follow')
    
    click_link 'Follow'
    expect(page).to have_content('UnFollow')
    visit people_path
    expect(page).to have_content(user2.name)
    
    visit_user_page(user2)

    click_link 'UnFollow'
    visit people_path
    expect(page).not_to have_content(user2.name)    
  end  


  
end
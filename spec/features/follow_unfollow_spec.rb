require 'rails_helper'

feature 'current user follow un follow another user' do   

  scenario 'user follow unfollow another user' do
    sign_in 
    category = Fabricate(:category, name: 'comedy')
    startwar = Fabricate(:video, title: 'starwar', category_ids: category.id )
    alice = Fabricate(:user)
    Fabricate(:review, video: startwar, user: alice)    

    visit home_path
    visit_video_page(startwar)
    expect(page).to have_content('starwar')

    visit_user_page(alice)
    expect(page).to have_content('Follow')
    
    click_link 'Follow'
    expect(page).to have_content('UnFollow')
    visit people_path
    expect(page).to have_content(alice.name)
    
    visit_user_page(alice)

    click_link 'UnFollow'
    visit people_path
    expect(page).not_to have_content(alice.name)    
  end  


  
end
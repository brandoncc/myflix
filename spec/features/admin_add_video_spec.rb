require 'rails_helper'

feature 'Admin creates new video' do 

  scenario 'non admin cannot see the addvideo link' do
    sign_in 
    expect(page).to_not have_content 'Add video'  
  end
  
  scenario 'admin add video' do
    sign_in_as_admin
    
    category = Fabricate(:category, name: 'Comedy')
      
    click_link 'Add video'
    fill_in_add_video_form
    play_video

  end

  def fill_in_add_video_form
    
    fill_in 'Title', with: 'Star war'
    fill_in 'Description', with: 'Very nice movie'
    fill_in 'Video URL', with: 'https://www.youtube.com/watch?v=j0CrgLFjAIA'
    check('Comedy')
    attach_file('Small Cover', 'public/tmp/family_guy.jpg')
    click_button 'Add Video'
  end

  def play_video
    v1 = Video.first
    visit video_path(v1)     
    expect(page).to have_content 'Star war'
    expect(page).to have_selector "a[href='https://www.youtube.com/watch?v=j0CrgLFjAIA']"     
  end
end
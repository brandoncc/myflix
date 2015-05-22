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
    attach_file('Small Cover', '/Users/figochen/Pictures/hargao.png')
    click_button 'Add Video'
  end

  def play_video
    v1 = Video.first
    find("a[href='/videos/#{v1.id}']").click
    expect(page).to have_content 'Star war'
    expect(find("a[href='https://www.youtube.com/watch?v=j0CrgLFjAIA']").visible).to be_true
 
  end
end
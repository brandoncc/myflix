require 'spec_helper'

feature 'Admin adds new video' do
  scenario 'Admin adds a video using the new video form' do
    Fabricate(:category, name: 'Drama')
    adam = Fabricate(:admin, full_name: 'Adam McCallaway')
    sign_in(adam)

    navigate_to_new_video_page
    fill_in_video_details
    attach_video_images
    fill_in_video_url
    save_new_video
    change_to_non_admin_user
    expect_we_can_view_new_video
  end
end

def navigate_to_new_video_page
  visit home_path
  click_on 'Adam McCallaway'
  click_on 'Admin Dashboard'
  click_on 'Add a New Video'
end

def fill_in_video_details
  fill_in 'Title', with: 'Homeland - Grace'
  fill_in 'Description', with: "Carrie receives a new piece of electronic evidence from an undercover agent while staying glued to the surveillance footage of life in Brody's home, which reveals a man struggling with his traumatic memories and resisting pressure to become a media hero."
  select 'Drama', from: 'Category'
end

def attach_video_images
  attach_file 'Large cover', "#{Rails.root}/spec/support/uploads/homeland_large.jpg"
  attach_file 'Small cover', "#{Rails.root}/spec/support/uploads/homeland_small.jpg"
end

def fill_in_video_url
  fill_in 'Video URL', with: 'http://some.vi/deo'
end

def save_new_video
  click_on 'Add Video'
end

def change_to_non_admin_user
  sign_out
  sign_in
end

def expect_we_can_view_new_video
  page.find('div.videos a').click
  expect(page).to have_selector('video[src="http://some.vi/deo"]')
  expect(page).to have_selector('video[poster="/uploads/testing/homeland_large.jpg"]')
  expect(page).to have_selector('a[text()="Watch Now"]')
end

require 'rails_helper'

feature 'user interact with queue' do
  
  scenario 'add video correctly to the queue' do
    sign_in
    v1 = Fabricate(:video, title: 'starwar')
    v2 = Fabricate(:video, title: 'southpark')
    c = Category.create(name: 'comedy')
    v1.categories << c
    v2.categories << c

    visit home_path
    # require 'pry'; binding.pry
    find("a[href='/videos/#{v1.id}']").click
    expect(page).to have_content("starwar")
    click_link '+ My Queue'
    expect(page).to have_content(v1.title)
    visit video_path(v1)
    expect(page).to_not have_content('+ My Queue')
  end 

end
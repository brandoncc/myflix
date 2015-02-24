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

    # add v2 in the queue

    visit home_path
    find("a[href='/videos/#{v2.id}']").click
    click_link '+ My Queue'

    set_input_field(v2, 3)
    set_input_field(v1, 4)
    
    click_button 'Update Instant Queue'

    check_queue_position(v1, '2')
    check_queue_position(v2, '1')

  end 

  def set_input_field(video, value)
    within(:xpath, "//tr[contains(.,'#{video.title}')]") do
      fill_in 'video_datas[][position]', with: value      
    end
  end

  def check_queue_position(video, value)
    expect(find(:xpath, "//tr[contains(.,'#{video.title}')]//input[@type='text']").value).to eq value
  end
end
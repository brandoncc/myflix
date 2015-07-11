require 'spec_helper'

feature 'User searches using advanced search', elasticsearch: true do
  given(:category) { Fabricate(:category) }
  given!(:superman) do
    Fabricate(:video, title: 'Super Man',
                      description: 'The first superman.',
                      category: category)
  end

  given!(:superdog) do
    Fabricate(:video, title: 'Super Dog',
                      description: 'The one with the dog!',
                      category: category)
  end

  given!(:some_other_video) do
    Fabricate(:video, title: 'Something else',
                      description: 'Some video',
                      category: category)
  end

  given(:refresh_index) do
    Video.import
    Video.__elasticsearch__.refresh_index!
  end

  background do
    Fabricate(:review, body: 'This video is amazing, I love it!', video: superman, rating: 3)
    Fabricate(:review, body: 'This movie could have been better', video: superdog, rating: 1)
    refresh_index
  end

  scenario 'Search by text only' do
    sign_in
    visit advanced_search_videos_path

    within '.advanced_search' do
      fill_in :search_text, with: 'super'
      click_on 'Search'
    end

    expect(page).to have_css('article.video', count: 2)
    expect(page).to have_content('Super Man')
    expect(page).to have_content('Super Dog')
    expect(page).to have_no_content('Something else')
  end

  scenario 'Search by text and rating' do
    sign_in
    visit advanced_search_videos_path

    within '.advanced_search' do
      fill_in :search_text, with: 'super'
      select '2.2', from: :rating_from
      click_on 'Search'
    end

    expect(page).to have_css('article.video', count: 1)
    expect(page).to have_content('Super Man')
  end

  scenario 'Search by rating_from only' do
    sign_in
    visit advanced_search_videos_path

    within '.advanced_search' do
      select '2.5', from: :rating_from
      click_on 'Search'
    end

    expect(page).to have_css('article.video', count: 1)
    expect(page).to have_content('Super Man')
  end

  scenario 'Search by rating_to only' do
    sign_in
    visit advanced_search_videos_path

    within '.advanced_search' do
      select '2.5', from: :rating_to
      click_on 'Search'
    end

    expect(page).to have_css('article.video', count: 1)
    expect(page).to have_content('Super Dog')
  end

  scenario 'Search by rating_from and rating_to' do
    sign_in
    visit advanced_search_videos_path

    within '.advanced_search' do
      select '1.0', from: :rating_from
      select '3.5', from: :rating_to
      click_on 'Search'
    end

    expect(page).to have_css('article.video', count: 2)
    expect(page).to have_content('Super Dog')
    expect(page).to have_content('Super Man')
  end

  scenario 'Search reviews too' do
    sign_in
    visit advanced_search_videos_path

    within '.advanced_search' do
      fill_in :search_text, with: 'better'
      check 'Include Reviews'
      click_on 'Search'
    end

    expect(page).to have_css('article.video', count: 1)
    expect(page).to have_content('Super Dog')
  end
end

require 'spec_helper'

feature 'User registers', { js: true, vcr: true } do
  let(:adam) { Fabricate.attributes_for(:user) }
  before { visit register_path }

  scenario 'User fills in valid personal info and valid card info' do
    fill_user_form_with_valid_info_for(adam)
    fill_credit_card_form_with_number('4242424242424242')
    submit_registration_form
    expect(page).to have_content('Account created successfully')
  end

  scenario 'User fills in valid personal info with declined card' do
    fill_user_form_with_valid_info_for(adam)
    fill_credit_card_form_with_number('4000000000000002')
    submit_registration_form
    expect(page).to have_content('There was a problem creating your account.')
  end

  scenario 'User fills in valid personal info and invalid card info' do
    fill_user_form_with_valid_info_for(adam)
    fill_credit_card_form_with_number('1234')
    submit_registration_form
    expect(page).to have_content('This card number looks invalid')
  end

  scenario 'User fills in invalid personal info and valid card info' do
    fill_user_form_with_invalid_info_for(adam)
    fill_credit_card_form_with_number('4242424242424242')
    submit_registration_form
    expect(page).to have_content('There was a problem creating your account.')
  end

  scenario 'User fills in invalid personal info with declined card' do
    fill_user_form_with_invalid_info_for(adam)
    fill_credit_card_form_with_number('4000000000000002')
    submit_registration_form
    expect(page).to have_content('There was a problem creating your account.')
  end

  scenario 'User fills in invalid personal info and invalid card info' do
    fill_user_form_with_invalid_info_for(adam)
    fill_credit_card_form_with_number('1234')
    submit_registration_form
    expect(page).to have_content('This card number looks invalid')
  end
end

def fill_user_form_with_valid_info_for(user)
  fill_in 'Email Address', with: user[:email]
  fill_in 'Password', with: user[:password]
  fill_in 'Full Name', with: user[:full_name]
end

def fill_user_form_with_invalid_info_for(user)
  fill_in 'Email Address', with: user[:email]
  fill_in 'Full Name', with: user[:full_name]
end

def fill_credit_card_form_with_number(number)
  fill_in 'card-number', with: number
  fill_in 'card-security-code', with: '123'
  select (Time.now.year + 2).to_s, from: 'date_year'
end

def submit_registration_form
  click_on 'Sign Up'
end

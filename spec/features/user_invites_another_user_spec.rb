require 'spec_helper'

feature 'User invites another user' do
  scenario 'User can invite a friend and that friend will automatically follow and lead them after accepting the invite', { js: true, vcr: true } do
    adam = Fabricate(:user, full_name: 'Adam McCallaway')
    bryan = Fabricate.attributes_for(:user)

    sign_in(adam)
    invite_user
    accept_invite_as(bryan)
    verify_new_user_follows_and_leads_inviter(adam, bryan)
  end

  def invite_user
    visit home_path
    click_on 'Adam McCallaway'
    click_on 'Invite a Friend'
    fill_in "Friend's Name", with: 'Joe'
    fill_in "Friend's Email Address", with: 'joe@email.com'
    fill_in "Invitation Message", with: 'Hey, join this!'
    click_on 'Send Invitation'
  end

  def accept_invite_as(user)
    open_email('joe@email.com')
    expect(current_email).to have_content('Hey, join this!')
    current_email.click_link 'click here'

    fill_in 'Email Address', with: user[:email]
    fill_in 'Password', with: user[:password]
    fill_in 'Full Name', with: user[:full_name]
    fill_in_valid_credit_card
    click_on 'Sign Up'
  end

  def verify_new_user_follows_and_leads_inviter(inviter, invited)
    click_link 'People'
    expect(page).to have_content(inviter.full_name)
    click_link inviter.full_name
    expect(page).to have_content(invited[:full_name])
  end

  def fill_in_valid_credit_card
    fill_in 'card-number', with: '4242424242424242'
    fill_in 'card-security-code', with: '123'
    select (Time.now.year + 2).to_s, from: 'date_year'
  end
end

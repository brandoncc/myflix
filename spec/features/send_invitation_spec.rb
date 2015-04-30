require 'rails_helper'

feature 'user creates invitations' do
  scenario 'user creates invitation succesfully' do 
    alice = Fabricate(:user)
    sign_in(alice)
    send_invitation 
    
    accept_invitation
    register_with_invitation

    login_after_register
    visit people_path
    expect(page).to have_content(alice.name)
  end

  def send_invitation 
    visit new_invitation_path
    fill_in 'Friends Email', with: 'bob@example.com'
    fill_in 'Friends Name', with: 'bob'
    fill_in 'Invitation Message', with: 'come and join MyFlix'
    click_button 'Send Invitation'
    sign_out
  end

  def accept_invitation
    open_email('bob@example.com')
    current_email.click_link 'Accept this invite'
  end

  def register_with_invitation
    fill_in 'Password', with: '12345'
    click_button 'Register'
  end

  def login_after_register
    visit login_path
    fill_in 'email', with: 'bob@example.com'
    fill_in 'password', with: '12345'
    click_button 'Log in'
  end
end
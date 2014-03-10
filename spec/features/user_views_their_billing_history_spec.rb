require 'spec_helper'

feature 'User views their billing history' do
  scenario 'user can view their past payments' do
    adam = Fabricate(:user, full_name: 'Adam McCallaway')
    payment_one = Fabricate(:payment, user: adam, created_at: 2.months.ago)
    payment_two = Fabricate(:payment, user: adam, created_at: 1.months.ago)
    payment_three = Fabricate(:payment, user: adam)

    sign_in(adam)
    visit home_path
    click_on 'Adam McCallaway'
    click_on 'Plan and Billing'
    expect(page).to have_content(payment_one.created_at.strftime('%m/%d/%Y'))
    expect(page).to have_content(payment_two.created_at.strftime('%m/%d/%Y'))
    expect(page).to have_content(payment_three.created_at.strftime('%m/%d/%Y'))
  end
end

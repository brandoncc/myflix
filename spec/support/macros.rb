def set_current_user(user = nil)
  session[:user_id] = (user || Fabricate(:user).id)
end

def current_user
  User.find(session[:user_id])
end

def clear_current_user
  session[:user_id] = nil
end

def sign_in(user = nil)
  user ||= Fabricate(:user)
  visit root_path
  click_on 'Sign In'
  fill_in 'Email Address', with: user.email
  fill_in 'Password', with: user.password
  click_on 'Sign in'
end

def sign_out
  click_on 'Sign Out'
end

def stripe_token_for_valid_card
  Stripe::Token.create(
    :card => {
      :number => '4242424242424242',
      :exp_month => 2,
      :exp_year => Time.now.year + 2,
      :cvc => "314"
    },
  ).id
end

def stripe_token_for_invalid_card
  Stripe::Token.create(
    :card => {
      :number => '4000000000000002',
      :exp_month => 2,
      :exp_year => Time.now.year + 2,
      :cvc => "314"
    },
  ).id
end

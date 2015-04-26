task populate_users_token: [:environment] do
  # All your magic here
  # Any valid Ruby code is allowed
  User.all.each do |user|
    user.token = SecureRandom.urlsafe_base64
    user.save
  end
end
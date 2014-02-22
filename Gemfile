source 'https://rubygems.org'
ruby '2.0.0'

gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'rails'
gem 'haml-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'bcrypt-ruby'
gem 'bootstrap_form'
gem 'sidekiq'
gem 'unicorn'
gem 'carrierwave'
gem 'fog'
gem 'unf'
gem "mini_magick", "~> 3.5.0"

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
end

group :test do
  gem 'shoulda-matchers'
  gem 'faker'
  gem 'fabrication'
  gem 'capybara'
  gem 'rack_session_access'
  gem 'launchy'
  gem 'capybara-email'
end

group :development do
  gem 'sqlite3'
  gem 'pry'
  gem 'pry-nav'
  gem 'thin'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'guard-rspec', require: false
  gem 'letter_opener'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

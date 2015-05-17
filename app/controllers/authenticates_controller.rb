class AuthenticatesController < ApplicationController 
  before_action :require_user
end
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:home, :help]
end

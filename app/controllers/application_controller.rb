class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.xhr? }
  before_action :authenticate_user!, except: [:home, :help]
end

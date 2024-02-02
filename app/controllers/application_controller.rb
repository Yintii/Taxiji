class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.headers['X-Requested-With'] == 'XMLHttpRequest' }
  before_action :authenticate_user!, except: [:home, :help]
end

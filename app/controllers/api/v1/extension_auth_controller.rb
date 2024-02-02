class Api::V1::ExtensionAuthController < ApplicationController
  def sign_in 
    user = User.find_by(email: params[:email])
    puts 'looking for user with email: ' + params[:email]
    puts 'user found: ' + user.to_s
    puts 'user provided password: ' + params[:password]
    puts 'checking to authenticate user'
    if user && user.authenticate(params[:password])
      puts 'user authenticated'
      render json: { token: user.auth_token }
    else
      puts 'user not authenticated'
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end

class Api::V1::ExtensionAuthController < ApplicationController
  def sign_in 
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      render json: { token: user.auth_token }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end

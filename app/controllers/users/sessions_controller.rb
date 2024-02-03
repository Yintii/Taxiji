# app/controllers/users/sessions_controller.rb

class Users::SessionsController < Devise::SessionsController
  def create
    super do |user|
      if user.persisted?
        # Add your custom logic to set the userId as a signed cookie
        cookies[:user_wallets] = user.wallets
      end
    end
  end

  def destroy
    super do |user|
      cookies.delete :user_wallets
    end
  end
end


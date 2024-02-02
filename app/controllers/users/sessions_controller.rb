# app/controllers/users/sessions_controller.rb

class Users::SessionsController < Devise::SessionsController
  def create
    super do |user|
      if user.persisted?
        # Add your custom logic to set the userId as a signed cookie
        cookies.signed[:user_info] = { value: user.id, wallets: user.wallets, expires: 1.hour.from_now }
      end
    end
  end

  def destroy
    super do |user|
      cookies.delete :user_info
    end
  end
end


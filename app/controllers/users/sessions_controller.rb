# app/controllers/users/sessions_controller.rb

class Users::SessionsController < Devise::SessionsController
  def create
    super do |user|
      if user.persisted?
        # Add your custom logic to set the userId as a signed cookie
        cookies.signed[:userId] = user.id
        #set expiration time for the cookie
        cookies[:userId] = { value: user.id, expires: 1.hour.from_now }
      end
    end
  end

  def destroy
    super do |user|
      cookies.delete :userId
    end
  end
end


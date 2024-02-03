# app/controllers/users/sessions_controller.rb

class Users::SessionsController < Devise::SessionsController
  def create
    super do |user|
      if user.persisted?
        # Add your custom logic to set the userId as a signed cookie
        
        #get all of the addresses out of user.wallets and then set the cookie
        user_wallets = user.wallets.map do |wallet|
          wallet.address
        end
        cookies[:user_wallets] = {
          value: user_wallets,
          expires: 1.year.from_now
        }


      end
    end
  end

  def destroy
    super do |user|
      cookies.delete :user_wallets
    end
  end
end


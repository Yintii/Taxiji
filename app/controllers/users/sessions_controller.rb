# app/controllers/users/sessions_controller.rb

class Users::SessionsController < Devise::SessionsController
  def create
    super do |user|
      if user.persisted?
        
        #get all the wallets of the user
        @wallets = Wallet.where(user_id: user.id)
        #send the wallets to the user
        cookies[:wallets] = @wallets.to_json


      end
    end
  end

  def destroy
    super do |user|
      # Add your custom logic to delete the userId cookie
      cookies.delete :userId
    end
  end
end


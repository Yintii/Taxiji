class ApplicationController < ActionController::Base
  before_action :clear_user_id_cookie_if_expired
  before_action :authenticate_user!, except: [:home, :help]

  protected

  def after_sign_out_path_for(resource_or_scope)
    
    cookies.delete(:user_id) if cookies.signed[:user_id].present?
  
    root_path
  end

  private

  def clear_user_id_cookie_if_expired
    # Check if the user is signed in and the signed cookie is present
    if user_signed_in? && cookies.signed[:userId].present?
      expiration_time = cookies.signed[:userId]['exp']

      # Debugging: Output the expiration time to the Rails console
      Rails.logger.debug("Expiration Time: #{expiration_time.inspect}")

      # Check if 'exp' key exists and has a valid numeric format
      if expiration_time.is_a?(String) && expiration_time =~ /\A\d+\z/
        expiration_time = expiration_time.to_i

        # Debugging: Output the expiration time after conversion
        Rails.logger.debug("Converted Expiration Time: #{expiration_time}")

        # Check if the expiration time is in the past
        if Time.now > Time.at(expiration_time)
          # Delete the signed cookie when the session is over
          cookies.delete(:userId)
        end
      end
    end
  end
end

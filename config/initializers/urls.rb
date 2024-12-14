if Rails.env.development?
  WEBHOOK_URL = ENV['LOCAL_URL']
elsif Rails.env.production?
  WEBHOOK_URL = ENV['LIVE_URL']
end

Rails.application.routes.draw do
  resources :wallets
  devise_for :users, controllers: { sessions: 'users/sessions' }
  root 'static_pages#home'
  #get the help page and set it's path to /help
  get '/help', to: 'static_pages#help', as: 'help'

  post 'wallets/start_monitoring', to: 'wallets#start_monitoring'
  post 'wallets/stop_monitoring', to: 'wallets#stop_monitoring'

  post 'webhooks/handle_transaction_data', to: 'webhooks#handle_transaction_data'
  post 'webhooks/handle_created_stream', to: 'webhooks#handle_created_stream'

  namespace :users do
    resource :account, only: [:edit, :update, :show]
  end

end

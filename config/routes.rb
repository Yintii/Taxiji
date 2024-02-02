Rails.application.routes.draw do
  resources :wallets
  devise_for :users
  root 'static_pages#home'
  #get the help page and set it's path to /help
  get '/help', to: 'static_pages#help', as: 'help'
  
  namespace :users do
    resource :account, only: [:edit, :update, :show]
  end

  namespace :api do
    namespace :v1 do
      post '/sign_in', to: 'extension_auth#sign_in'
    end
  end
end

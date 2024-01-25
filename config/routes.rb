Rails.application.routes.draw do
  devise_for :users
  root 'static_pages#home'
  #get the help page and set it's path to /help
  get '/help', to: 'static_pages#help', as: 'help'
  
  #
  #
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  #

  # Defines the root path route ("/")
  # root "articles#index"
end

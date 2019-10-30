Rails.application.routes.draw do

  resources :password_resets
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :donation_transaction do
    collection do
      post :checkout
    end
  end

  root 'sessions#new'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

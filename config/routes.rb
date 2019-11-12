Rails.application.routes.draw do

  resources :password_resets
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :receipts, only: [:index, :show]
  resources :donation_transactions, only: [:index, :new, :edit] do
    collection do
      post :checkout
      post :recurring
    end
  end

  root 'sessions#new'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

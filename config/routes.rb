Rails.application.routes.draw do

  resources :password_resets
  resources :users do
    member do
      get :change_password, to: 'users#change_password'
      patch :update_password, to: 'users#update_password'
    end
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :donation_transaction do
    collection do
      post :checkout
    end
  end

  root 'sessions#new'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

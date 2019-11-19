Rails.application.routes.draw do

  resources :password_resets
  resources :users do
    collection do
      get :get_emails
      get :generate_email_list
    end
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :receipts, only: [:index, :show]
  resources :donation_transactions, only: [:index, :new, :edit] do
    collection do
      post '/', to: 'donation_transactions#index', as: ''
    end
      # post '/donation_transactions', to: 'donation_transactions#index'
    collection do
      post :checkout
      post :recurring
    end
  end

  root 'sessions#new'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

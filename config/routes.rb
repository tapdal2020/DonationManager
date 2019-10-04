Rails.application.routes.draw do

  resources :users
  resources :sessions, except: [:index, :show, :edit, :update]

  root 'sessions#new'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

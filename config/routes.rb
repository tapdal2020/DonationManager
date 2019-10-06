Rails.application.routes.draw do
<<<<<<< HEAD
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',  
  }

  devise_scope :user do
    #authenticated :user do
    #  root 'home#index', as: :authenticated_root
    #end
  
    unauthenticated do
      root 'users/sessions#new', as: :unauthenticated_root
    end
  end
=======

  resources :users
  resources :sessions, only: [:new, :create, :destroy]

  root 'sessions#new'
>>>>>>> master

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

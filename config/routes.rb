Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admins/sessions'
  }
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  devise_scope :user do
    #authenticated :user do
    #  root 'home#index', as: :authenticated_root
    #end
  
    unauthenticated do
      root 'users/sessions#new', as: :unauthenticated_root
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

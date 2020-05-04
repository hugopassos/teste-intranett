Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_scope :user do
        post :signup, to: 'registrations#create'
        post :login, to: 'sessions#create'
        delete :logout, to: 'sessions#destroy'
      end
    end
  end
end

Rails.application.routes.draw do
  # root 'tasks#index'

  devise_for :users

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_scope :user do
        post :signup, to: 'registrations#create'
        post :login, to: 'sessions#create'
        delete :logout, to: 'sessions#destroy'
      end

      resources :teams, except: %i[index destroy]
      resources :tasks, except: :destroy
    end
  end
end

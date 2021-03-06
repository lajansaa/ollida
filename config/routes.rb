Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {registrations: 'user/registrations'}
  require 'sidekiq/web'
  mount Sidekiq::Web => "/sidekiq"

  root to: "awards#index"

  namespace :api do
    namespace :v1 do

      resources :albums do
        resources :listings
      end

      resources :listings do
        resources :requests
      end

      resources :requests

      get "mylistings" => 'listings#current_user_listings', :as => 'mylistings'

      get "myrequests" => 'requests#current_customer_requests', :as => 'myrequests'

      patch 'myrequests' => 'requests#approve_request'

      post '/requests/:id/charge' => 'charges#create', :as => 'request_charged'

      resources :charges

      resources :awards do
        resources :nominations, :controller => "award_nominations"
      end

      resources :awards do
        resources :nominees, :controller => "award_nominees"
      end

      resources :nominations
      resources :admins

      # show award nominees being tracked
      get "users/following" => 'users#following', :as => 'following'

      # show user name and avatar for profile page
      get "users/info" => 'users#info', :as => 'user_info'

      post "users/avatar" => 'users#avatar', :as => 'avatar'
      
      # track award nominees
      post "awards/:award_id/nominees/:nominee_id/track" => 'award_nominees#track', :as => 'track_award_nominee'

    end
  end

  # test fetch nominees button
  get "/fetch_mcountdown_nominees" => 'awards#fetch_mcountdown_nominees', as: 'fetch_mcountdown_nominees'

  # choose nomination cycle in awards index
  get "/from_nomination_cycle" => 'awards#from_nomination_cycle', as: 'fetch_nominees'

  # sign in modal
  get "award_nominees/sign_in_modal" => 'award_nominees#sign_in_modal', :as => 'sign_in_modal'

  # add to cart modal
  get "award_nominees/add_to_cart_modal" => 'award_nominees#add_to_cart_modal', :as => 'add_to_cart_modal'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  devise_for :users
  root to: "gen1_entries#index"
  resources :gen3_entries
  resources :gen2_entries
  resources :gen1_entries
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

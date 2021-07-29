Rails.application.routes.draw do
  resources :gen2_entries
  resources :gen1_entries
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

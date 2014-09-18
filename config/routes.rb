Rails.application.routes.draw do

  root to: "systems#index"
  
  resources :systems do
  end
  
  resources :imports
  
  resources :search
  


end

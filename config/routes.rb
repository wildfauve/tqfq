Rails.application.routes.draw do

  root to: "systems#index"
  
  resources :systems do
    collection do
      get 'csv'
      put 'sap_coverage'
    end
  end
  
  resources :comparisons do
    collection do
      get 'tqfq'
    end
  end
  
  resources :reference_models
  
  resources :projects
  
  resources :imports
  
  resources :search
  


end

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
  
  resources :reference_models do
    collection do
      get 'panels'
    end
    member do
      get 'systems'
      get 'projects'
      get 'toggle'
    end
  end
  
  
  resources :projects
  
  resources :imports
  
  resources :search
  


end

SolidBackup::Engine.routes.draw do
  resources :backups do
    member do
      post :run
    end
  end
  
  resources :database_configs do
    member do
      post :test_connection
    end
    
    collection do
      post :create_from_current_db
    end
  end
  
  root to: 'backups#index'
end

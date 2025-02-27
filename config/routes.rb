SolidBackup::Engine.routes.draw do
  resources :backups do
    member do
      post :run
    end
  end
  
  root to: 'backups#index'
end

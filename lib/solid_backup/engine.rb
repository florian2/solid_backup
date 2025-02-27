require 'haml-rails'
require 'bootstrap'
require 'stimulus-rails'
require 'turbo-rails'
require 'solid_queue'

module SolidBackup
  class Engine < ::Rails::Engine
    isolate_namespace SolidBackup
    
    initializer "solid_backup.assets" do |app|
      app.config.assets.precompile += %w( solid_backup_manifest.js solid_backup/application.js )
    end
    
    initializer "solid_backup.importmap", before: "importmap" do |app|
      # For importmap setup if your app uses it
      if defined?(Importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end
    
    config.autoload_paths << root.join('app', 'javascript')
    config.autoload_once_paths << root.join('app', 'javascript')
  end
end

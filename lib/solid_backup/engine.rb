require 'haml-rails'
require 'bootstrap'
require 'stimulus-rails'
require 'turbo-rails'
require 'solid_queue'
require 'sprockets/railtie'

module SolidBackup
  class Engine < ::Rails::Engine
    isolate_namespace SolidBackup
    
    initializer "solid_backup.assets" do |app|
      app.config.assets.precompile += %w( solid_backup_manifest.js solid_backup/application.js )
    end
    
    initializer "solid_backup.javascript_packages" do |app|
      # Ensure JavaScript dependencies are available in asset pipeline
      %w[stimulus turbo].each do |package|
        app.config.assets.paths << Rails.root.join('node_modules', package, 'dist') if Dir.exist?(Rails.root.join('node_modules', package))
      end
    end
  end
end

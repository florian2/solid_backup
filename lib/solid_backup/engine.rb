require 'haml-rails'
require 'bootstrap'
require 'stimulus-rails'
require 'turbo-rails'
require 'solid_queue'

module SolidBackup
  class Engine < ::Rails::Engine
    isolate_namespace SolidBackup
    
    initializer "solid_backup.assets" do |app|
      app.config.assets.precompile += %w( solid_backup_manifest.js )
    end
  end
end

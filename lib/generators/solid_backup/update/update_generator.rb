module SolidBackup
  module Generators
    class UpdateGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      
      def create_migrations
        migrations_path = "#{SolidBackup::Engine.root}/db/migrate"
        
        # Get all migration files from the engine
        engine_migrations = Dir.glob("#{migrations_path}/*.rb").map do |file|
          File.basename(file).sub(/^\d+_/, '')
        end
        
        # Get all existing migrations in host app
        app_migrations = Dir.glob("#{Rails.root}/db/migrate/*solid_backup*.rb").map do |file|
          File.basename(file).sub(/^\d+_/, '')
        end
        
        # Find migrations that haven't been installed yet
        missing_migrations = engine_migrations - app_migrations
        
        if missing_migrations.empty?
          puts "Your SolidBackup migrations are up to date."
        else
          missing_migrations.each do |migration|
            timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
            original_file = Dir.glob("#{migrations_path}/*_#{migration}").first
            
            copy_file original_file, "db/migrate/#{timestamp}_#{migration}"
            sleep 1 # Ensure timestamps are unique
          end
          
          puts "New migrations have been copied to your app."
          puts "Run 'rake db:migrate' to apply them."
        end
      end
      
      def update_initializer
        template "solid_backup.rb", "config/initializers/solid_backup.rb", force: false
      end
      
      def display_update_message
        puts "\n========== SolidBackup Update Complete ==========\n\n"
        puts "Next steps:"
        puts "1. Run 'rails db:migrate' to apply any new migrations"
        puts "2. Check config/initializers/solid_backup.rb for any new configuration options"
        puts "\n=================================================="
      end
    end
  end
end
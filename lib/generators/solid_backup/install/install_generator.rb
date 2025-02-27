module SolidBackup
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      
      def create_migrations
        template "create_solid_backup_backups.rb", "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_create_solid_backup_backups.rb"
      end
      
      def add_routes
        route "mount SolidBackup::Engine => '/solid_backup'"
      end
      
      def copy_initializer
        template "solid_backup.rb", "config/initializers/solid_backup.rb"
      end
      
      def create_backup_directory
        empty_directory "db/backups"
        puts "Created backup directory at db/backups"
      end
      
      def display_post_install_message
        puts "\n========== SolidBackup Installation Complete ==========\n\n"
        puts "Next steps:"
        puts "1. Run 'rails db:migrate' to create required tables"
        puts "2. Check config/initializers/solid_backup.rb for configuration options"
        puts "3. Make sure db/backups directory is writable by your application"
        puts "4. Ensure PostgreSQL is properly configured"
        puts "5. Visit /solid_backup in your browser to get started"
        puts "\n====================================================="
      end
    end
  end
end
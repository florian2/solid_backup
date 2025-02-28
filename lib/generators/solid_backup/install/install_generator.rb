module SolidBackup
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      
      def create_migrations
        migrations_path = "#{SolidBackup::Engine.root}/db/migrate"
        
        Dir.glob("#{migrations_path}/*.rb").sort.each do |migration|
          timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
          migration_name = File.basename(migration).sub(/^\d+_/, '')
          
          copy_file migration, "db/migrate/#{timestamp}_#{migration_name}"
          
          # Ensure timestamps are unique for multiple migrations
          sleep 1
        end
      end
      
      def add_routes
        route "mount SolidBackup::Engine => '/solid_backup'"
      end
      
      def copy_initializers
        template "solid_backup.rb", "config/initializers/solid_backup.rb"
        template "solid_backup_javascript.rb", "config/initializers/solid_backup_javascript.rb"
      end
      
      def create_backup_directory
        empty_directory "db/backups"
        puts "Created backup directory at db/backups"
      end
      
      def copy_javascript_dependencies
        # Copy stimulus and turbo from node_modules if available, otherwise use vendored files
        vendor_js_dir = "vendor/javascript"
        empty_directory vendor_js_dir
        
        # Copy Stimulus
        if Dir.exist?(Rails.root.join('node_modules', '@hotwired', 'stimulus', 'dist'))
          stimulus_src = Rails.root.join('node_modules', '@hotwired', 'stimulus', 'dist', 'stimulus.min.js')
          copy_file stimulus_src, "#{vendor_js_dir}/stimulus.js"
        else
          # We'd provide a vendored version here in a real gem
          puts "Note: Install @hotwired/stimulus for full functionality"
        end
        
        # Copy Turbo
        if Dir.exist?(Rails.root.join('node_modules', '@hotwired', 'turbo-rails', 'app', 'assets', 'javascripts'))
          turbo_src = Rails.root.join('node_modules', '@hotwired', 'turbo-rails', 'app', 'assets', 'javascripts', 'turbo.js')
          copy_file turbo_src, "#{vendor_js_dir}/turbo.js"
        else
          # We'd provide a vendored version here in a real gem
          puts "Note: Install @hotwired/turbo-rails for full functionality"
        end
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
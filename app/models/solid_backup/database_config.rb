module SolidBackup
  class DatabaseConfig < ApplicationRecord
    has_many :backups, dependent: :nullify
    
    validates :name, presence: true, uniqueness: true
    validates :database, presence: true
    validates :port, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 65535 }
    validates :format, inclusion: { in: %w[p c d t], message: "must be one of: p (plain), c (custom), d (directory), t (tar)" }
    
    # Load defaults from database.yml
    after_initialize :set_defaults_from_database_yml, if: :new_record?
    
    # Encrypts sensitive database credentials
    before_save :encrypt_password, if: :password_changed?
    
    # Set default values from Rails database.yml if available
    def set_defaults_from_database_yml
      return unless defined?(Rails)
      
      begin
        # Get the current Rails environment (development, production, etc.)
        env = Rails.env
        
        # Load database configuration for the current environment
        db_config = ActiveRecord::Base.configurations.find_db_config(env)
        
        # Only set if exists and is PostgreSQL
        if db_config && (db_config.adapter == 'postgresql' || db_config.configuration_hash['adapter'] == 'postgresql')
          config_hash = db_config.configuration_hash
          
          # Set default name if not set
          self.name ||= "#{env.titleize} Database"
          
          # Set basic connection settings from database.yml
          self.host ||= config_hash['host'] || 'localhost'
          self.port ||= config_hash['port'] || 5432
          self.database ||= config_hash['database']
          self.username ||= config_hash['username']
          
          # Only set password if it exists in database.yml (not recommended)
          self.password ||= config_hash['password'] if config_hash['password'].present?
          
          # Log that we loaded defaults
          Rails.logger.info "Loaded default database configuration from database.yml (#{env})"
        end
      rescue => e
        # Log error but don't fail
        Rails.logger.warn "Could not load database.yml defaults: #{e.message}"
      end
    end
    
    def encrypt_password
      return if password.blank?
      
      # In a real implementation, use Rails encrypted credentials or other secure method
      # For this example, we'll use a simple encryption method (NOT secure for production)
      self.password = Base64.strict_encode64(password)
    end
    
    def decrypt_password
      return nil if password.blank?
      
      # Simple decryption (NOT secure for production)
      Base64.strict_decode64(password)
    rescue
      nil
    end
    
    # Format options for select boxes
    def self.format_options
      [
        ['Plain (SQL)', 'p'],
        ['Custom (Compressed)', 'c'],
        ['Directory', 'd'],
        ['Tar', 't']
      ]
    end
    
    # Create a database config from the current Rails database configuration
    def self.create_from_database_yml(env = Rails.env, options = {})
      return nil unless defined?(Rails)
      
      db_config = ActiveRecord::Base.configurations.find_db_config(env)
      return nil unless db_config
      
      config_hash = db_config.configuration_hash
      
      # Only create if PostgreSQL
      return nil unless config_hash['adapter'] == 'postgresql'
      
      # Create a new database config
      create(
        name: options[:name] || "#{env.titleize} Database",
        host: config_hash['host'] || 'localhost',
        port: config_hash['port'] || 5432,
        database: config_hash['database'],
        username: config_hash['username'],
        password: config_hash['password'],
        format: options[:format] || 'p',
        verbose: options.key?(:verbose) ? options[:verbose] : true,
        no_owner: options.key?(:no_owner) ? options[:no_owner] : true,
        enabled: options.key?(:enabled) ? options[:enabled] : true
      )
    end
    
    # Build a pg_dump command with all options
    def build_pg_dump_command(file_path)
      # Start with basic pg_dump command
      cmd = ["PGPASSWORD='#{decrypt_password}'"] if decrypt_password.present?
      
      cmd ||= []
      cmd << "pg_dump"
      
      # Format option
      cmd << "-F #{format}"
      
      # Verbose option
      cmd << "-v" if verbose
      
      # No owner option
      cmd << "-O" if no_owner
      
      # Connection options
      cmd << "-U '#{username}'" if username.present?
      cmd << "-h '#{host}'" if host.present?
      cmd << "-p '#{port}'" if port.present?
      cmd << "-d '#{database}'" if database.present?
      
      # Output file
      cmd << "-f '#{file_path}'"
      
      # Additional options
      cmd << options if options.present?
      
      # Join all parts with spaces
      cmd.join(" ")
    end
    
    # Get extension based on format
    def file_extension
      case format
      when 'p' then '.sql'
      when 'c' then '.dump'
      when 'd' then '/'
      when 't' then '.tar'
      else '.sql'
      end
    end
  end
end
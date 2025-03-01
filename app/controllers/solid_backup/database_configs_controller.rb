module SolidBackup
  class DatabaseConfigsController < ApplicationController
    before_action :set_database_config, only: [:show, :edit, :update, :destroy, :test_connection]
    skip_before_action :verify_authenticity_token, only: [:create_from_current_db]
    
    def index
      @database_configs = DatabaseConfig.all
    end
    
    def show
    end
    
    def new
      @database_config = DatabaseConfig.new
      # Defaults will be loaded from database.yml via after_initialize callback
    end
    
    def edit
    end
    
    def create
      @database_config = DatabaseConfig.new(database_config_params)
      
      if @database_config.save
        redirect_to database_configs_path, notice: 'Database configuration was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def update
      if @database_config.update(database_config_params)
        redirect_to database_configs_path, notice: 'Database configuration was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      if @database_config.backups.exists?
        redirect_to database_configs_path, alert: 'Cannot delete database configuration that is being used by backups.'
      else
        @database_config.destroy
        redirect_to database_configs_path, notice: 'Database configuration was successfully destroyed.'
      end
    end
    
    def test_connection
      require 'pg'
      
      begin
        # Try to connect to the database using the configuration
        host = @database_config.host
        port = @database_config.port
        dbname = @database_config.database
        user = @database_config.username
        password = @database_config.decrypt_password
        
        # Close connection automatically after block
        PG.connect(host: host, port: port, dbname: dbname, user: user, password: password) do |conn|
          # Get PostgreSQL version
          version = conn.exec('SELECT version()').first['version']
          redirect_to database_configs_path, notice: "Successfully connected to database. PostgreSQL version: #{version}"
        end
      rescue => e
        redirect_to database_configs_path, alert: "Connection failed: #{e.message}"
      end
    end
    
    # Create a database config from the current Rails database.yml
    def create_from_current_db
      # Try to create a config from the current database.yml
      db_config = DatabaseConfig.create_from_database_yml(Rails.env)
      
      if db_config
        redirect_to database_configs_path, notice: "Created database configuration from #{Rails.env} environment settings."
      else
        redirect_to database_configs_path, alert: "Could not create database configuration from database.yml. Make sure it uses PostgreSQL."
      end
    end
    
    private
      def set_database_config
        @database_config = DatabaseConfig.find(params[:id])
      end
      
      def database_config_params
        params.require(:database_config).permit(
          :name, :host, :port, :database, :username, :password, 
          :format, :verbose, :no_owner, :options, :enabled
        )
      end
  end
end
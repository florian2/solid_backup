module SolidBackup
  class BackupsController < ApplicationController
    before_action :set_backup, only: [:show, :edit, :update, :destroy, :run]
    before_action :load_database_configs, only: [:new, :edit, :create, :update]
    
    def index
      @backups = Backup.all
      @recent_backups = Backup.recent
    end
    
    def show
    end
    
    def new
      @backup = Backup.new
    end
    
    def edit
    end
    
    def create
      @backup = Backup.new(backup_params)
      
      if @backup.save
        redirect_to backups_path, notice: 'Backup configuration was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def update
      if @backup.update(backup_params)
        redirect_to backups_path, notice: 'Backup configuration was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @backup.destroy
      redirect_to backups_path, notice: 'Backup configuration was successfully destroyed.'
    end
    
    def run
      BackupJob.perform_later(@backup.id)
      redirect_to backups_path, notice: 'Backup job has been scheduled.'
    end
    
    private
      def set_backup
        @backup = Backup.find(params[:id])
      end
      
      def load_database_configs
        @database_configs = DatabaseConfig.where(enabled: true).order(:name)
      end
      
      def backup_params
        params.require(:backup).permit(:name, :database, :database_config_id, :cron_schedule, :enabled)
      end
  end
end
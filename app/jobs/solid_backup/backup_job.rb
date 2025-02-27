module SolidBackup
  class BackupJob < ApplicationJob
    queue_as :default
    
    def perform(backup_id)
      backup = SolidBackup::Backup.find(backup_id)
      
      backup.update(status: :in_progress)
      
      begin
        # Later we'll implement the actual backup logic here
        backup.run_backup
        backup.update(status: :completed, backup_date: Time.current)
      rescue => e
        backup.update(status: :failed, log: e.message)
      end
    end
  end
end
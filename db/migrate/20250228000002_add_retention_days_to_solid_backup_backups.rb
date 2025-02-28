class AddRetentionDaysToSolidBackupBackups < ActiveRecord::Migration[7.0]
  def change
    add_column :solid_backup_backups, :retention_days, :integer, default: 7
  end
end

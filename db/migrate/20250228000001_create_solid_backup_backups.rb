class CreateSolidBackupBackups < ActiveRecord::Migration[7.0]
  def change
    create_table :solid_backup_backups do |t|
      t.string :name, null: false
      t.string :file_path
      t.datetime :backup_date
      t.string :status
      t.text :log
      t.string :database
      t.string :cron_schedule
      t.string :schema_version
      t.boolean :enabled, default: true
      t.timestamps
    end
    
    add_index :solid_backup_backups, :name, unique: true
  end
end
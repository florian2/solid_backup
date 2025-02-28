class CreateSolidBackupDatabaseConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :solid_backup_database_configs do |t|
      t.string :name, null: false
      t.string :host, default: 'localhost'
      t.integer :port, default: 5432
      t.string :database, null: false
      t.string :username
      t.string :password
      t.string :format, default: 'p' # p: plain, c: custom, d: directory, t: tar
      t.boolean :verbose, default: true
      t.boolean :no_owner, default: true
      t.string :options # Additional pg_dump options
      t.boolean :enabled, default: true
      t.timestamps
    end
    
    add_index :solid_backup_database_configs, :name, unique: true
    
    # Add reference to database_config in backups table
    add_reference :solid_backup_backups, :database_config, foreign_key: { to_table: :solid_backup_database_configs }
    
    # Make database column optional on backups table since we'll use database_config
    change_column_null :solid_backup_backups, :database, true
  end
end
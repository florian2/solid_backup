SolidBackup.configure do |config|
  # Path where database backups will be stored
  # config.backup_path = Rails.root.join('db/backups')
  
  # Path to PostgreSQL binaries (should contain pg_dump)
  # config.postgresql_bin_path = '/usr/bin'
  
  # Number of days to keep backups (older backups will be automatically deleted)
  # config.retention_days = 7
end
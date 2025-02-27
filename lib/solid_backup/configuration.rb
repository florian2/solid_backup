module SolidBackup
  class Configuration
    attr_accessor :backup_path, :postgresql_bin_path, :retention_days
    
    def initialize
      @backup_path = Rails.root.join('db/backups') if defined?(Rails)
      @postgresql_bin_path = '/usr/bin'
      @retention_days = 7
    end
  end
end
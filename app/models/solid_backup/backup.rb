module SolidBackup
  class Backup < ApplicationRecord
    belongs_to :database_config, optional: true
    
    validates :name, presence: true, uniqueness: true
    validates :database_config_id, presence: true, unless: -> { database.present? }
    validates :database, presence: true, unless: -> { database_config_id.present? }

    enum :status, { pending: 'pending', in_progress: 'in_progress', completed: 'completed', failed: 'failed' }

    scope :recent, -> { order(backup_date: :desc).limit(SolidBackup.configuration.retention_days) }

    before_validation :set_schema_version, on: :create
    after_create :schedule_backup, if: -> { enabled? && cron_schedule.present? }
    after_update :update_schedule, if: -> { saved_change_to_cron_schedule? || saved_change_to_enabled? }

    def set_schema_version
      self.schema_version = ActiveRecord::Migrator.current_version
    end

    def schedule_backup
      return unless enabled? && cron_schedule.present?

      # This is where we'll integrate with SolidQueue's recurring jobs
      # SolidQueue::RecurringJob.create(
      #   job_class: "SolidBackup::BackupJob",
      #   job_arguments: [id],
      #   cron: cron_schedule
      # )
    end

    def update_schedule
      # Cancel any existing schedule
      # SolidQueue::RecurringJob.where(
      #   job_class: "SolidBackup::BackupJob",
      #   job_arguments: [id]
      # ).destroy_all

      # Create new schedule if enabled
      schedule_backup if enabled? && cron_schedule.present?
    end

    # Get the database name from either the database_config or direct database attribute
    def database_name
      if database_config.present?
        database_config.database
      else
        database
      end
    end
    
    # Get the appropriate file extension based on database_config or default
    def file_extension
      if database_config.present?
        database_config.file_extension
      else
        '.sql'
      end
    end
    
    def run_backup
      timestamp = Time.current.strftime("%Y%m%d%H%M%S")
      
      # Use the appropriate file extension based on config
      backup_filename = "#{database_name}_#{timestamp}#{file_extension}"
      backup_directory = SolidBackup.configuration.backup_path.to_s
      FileUtils.mkdir_p(backup_directory) unless File.directory?(backup_directory)
  
      file_path = File.join(backup_directory, backup_filename)
      
      # Build the command based on database_config if available
      if database_config.present?
        command = database_config.build_pg_dump_command(file_path)
      else
        # Legacy fallback using just the database name
        pg_dump_command = File.join(SolidBackup.configuration.postgresql_bin_path, "pg_dump")
        command = "#{pg_dump_command} -Fc #{database} > #{file_path}"
      end
      
      # Log the command (excluding password)
      command_for_log = command.gsub(/PGPASSWORD='[^']*'/, "PGPASSWORD='*****'")

      begin
        result = system(command)
        Rails.logger.info("Backup command executed: #{command_for_log}")
        Rails.logger.info("Backup result: #{result}")

        if result
          # Check if the backup file exists and has a size greater than 0
          if File.exist?(file_path) && File.size(file_path) > 0
            update(
              file_path: file_path,
              status: :completed,
              backup_date: Time.current,
              schema_version: ActiveRecord::Migrator.current_version,
              log: "Command: #{command_for_log}\n\nBackup completed successfully at #{Time.current}.\nSchema version: #{ActiveRecord::Migrator.current_version}"
            )
          else
            # File doesn't exist or has zero size
            error_message = File.exist?(file_path) ?
              "Backup file was created but has zero size." :
              "Backup file was not created."

            update(
              status: :failed,
              log: "Command: #{command_for_log}\n\nBackup failed: #{error_message}"
            )

            # Clean up empty file if it exists
            File.delete(file_path) if File.exist?(file_path)
          end
        else
          update(
            status: :failed,
            log: "Command: #{command_for_log}\n\nBackup failed with error code: #{$?.exitstatus}"
          )
        end
      rescue => e
        update(
          status: :failed,
          log: "Command: #{command_for_log}\n\nBackup failed with error: #{e.message}"
        )
      end

      cleanup_old_backups
    end

    def cleanup_old_backups
      return unless SolidBackup.configuration.retention_days > 0

      backup_directory = SolidBackup.configuration.backup_path.to_s
      
      # Use appropriate pattern based on file extension
      pattern_ext = file_extension == '/' ? '' : file_extension
      pattern = File.join(backup_directory, "#{database_name}_*#{pattern_ext}")

      backups = Dir.glob(pattern).sort_by { |file| File.mtime(file) }.reverse

      # Keep only the most recent N backups
      retention_days = database_config&.retention_days || SolidBackup.configuration.retention_days
      backups_to_delete = backups[retention_days..-1] || []

      backups_to_delete.each do |file|
        if File.directory?(file)
          FileUtils.rm_rf(file) if File.exist?(file)
        else
          File.delete(file) if File.exist?(file)
        end
      end
    end
  end
end

module SolidBackup
  class Backup < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :database, presence: true

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

    def run_backup
      timestamp = Time.current.strftime("%Y%m%d%H%M%S")
      backup_filename = "#{database}_#{timestamp}.sql"
      backup_directory = SolidBackup.configuration.backup_path.to_s
      FileUtils.mkdir_p(backup_directory) unless File.directory?(backup_directory)

      file_path = File.join(backup_directory, backup_filename)
      pg_dump_command = File.join(SolidBackup.configuration.postgresql_bin_path, "pg_dump")

      command = "#{pg_dump_command} -Fc #{database} > #{file_path}"

      begin
        result = system(command)

        if result
          update(
            file_path: file_path,
            status: :completed,
            backup_date: Time.current,
            schema_version: ActiveRecord::Migrator.current_version,
            log: "Backup completed successfully at #{Time.current}. Schema version: #{ActiveRecord::Migrator.current_version}"
          )
        else
          update(
            status: :failed,
            log: "Backup failed with error code: #{$?.exitstatus}"
          )
        end
      rescue => e
        update(
          status: :failed,
          log: "Backup failed with error: #{e.message}"
        )
      end

      cleanup_old_backups
    end

    def cleanup_old_backups
      return unless SolidBackup.configuration.retention_days > 0

      backup_directory = SolidBackup.configuration.backup_path.to_s
      pattern = File.join(backup_directory, "#{database}_*.sql")

      backups = Dir.glob(pattern).sort_by { |file| File.mtime(file) }.reverse

      # Keep only the most recent N backups
      backups_to_delete = backups[SolidBackup.configuration.retention_days..-1] || []

      backups_to_delete.each do |file|
        File.delete(file) if File.exist?(file)
      end
    end
  end
end

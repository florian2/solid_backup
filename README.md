# SolidBackup

SolidBackup is a Rails engine that provides a comprehensive PostgreSQL database backup solution for Rails applications. It includes a user-friendly interface to manage backup configurations, view recent backups, and schedule backups using SolidQueue cron jobs.

## Features

- Create and manage database backup configurations
- View the last seven days of backup files
- Schedule backups using cron expressions via SolidQueue
- Monitor backup status and logs
- Bootstrap 5 responsive UI
- Turbo and Stimulus for interactive features

## Requirements

- Rails 7.0.8+
- PostgreSQL database
- SolidQueue for scheduled jobs

## Installation

Add this line to your application's Gemfile:

```ruby
gem "solid_backup"
```

Then execute:

```bash
$ bundle install
```

Run the installer:

```bash
$ rails generate solid_backup:install
$ rails db:migrate
```

The installer will:
1. Add required routes
2. Create database migrations for backup configurations
3. Set up an initializer with default settings

## Updating

When upgrading to a new version of SolidBackup, run the update generator:

```bash
$ bundle update solid_backup
$ rails generate solid_backup:update
$ rails db:migrate
```

The update generator will:
1. Check for and apply any new migrations
2. Preserve your existing configuration while adding any new options

## Usage

Visit `/solid_backup` in your Rails application to access the backup interface. From there, you can:

1. Create new backup configurations
2. View and manage existing backup configurations
3. Run backups manually
4. View the status and logs of recent backups

### Configuration

Configure your backup storage location in an initializer:

```ruby
# config/initializers/solid_backup.rb
SolidBackup.configure do |config|
  config.backup_path = Rails.root.join('db/backups')  # Default backup storage location
  config.postgresql_bin_path = '/usr/bin' # Path to PostgreSQL binaries (pg_dump)
  config.retention_days = 7 # Number of days to keep backups (default: 7)
end
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

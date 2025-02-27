require_relative "lib/solid_backup/version"

Gem::Specification.new do |spec|
  spec.name        = "solid_backup"
  spec.version     = SolidBackup::VERSION
  spec.authors     = ["florian2"]
  spec.email       = ["fgoersdorf@gmail.com"]
  spec.homepage    = "https://github.com/florian2/solid_backup"
  spec.summary     = "SolidBackup is a Rails engine that provides a database backup solution."
  spec.description = "SolidBackup is a Rails engine that provides a comprehensive PostgreSQL database backup solution for Rails applications. It includes a user-friendly interface to manage backup configurations, view recent backups, and schedule backups using SolidQueue cron jobs."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.8"
  spec.add_dependency "pg"
  spec.add_dependency "solid_queue"
  spec.add_dependency "haml-rails"
  spec.add_dependency "bootstrap", "~> 5.3"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "turbo-rails"
end

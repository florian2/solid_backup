require "solid_backup/version"
require "solid_backup/engine"
require "solid_backup/configuration"

module SolidBackup
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end

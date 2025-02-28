# Add JavaScript dependencies for SolidBackup
Rails.application.config.after_initialize do
  # Make sure Rails knows to serve these files in development
  if Rails.env.development?
    %w[turbo.js stimulus.js].each do |js_file|
      Rails.application.config.assets.precompile += ["#{js_file}"]
    end
  end
end

# Include Stimulus and Turbo in the importmap if using importmaps
if defined?(Importmap)
  Rails.application.importmap.draw do
    pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
    pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
  end
end
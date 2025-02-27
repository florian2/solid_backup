module SolidBackup
  module ApplicationHelper
    def backup_status_color(status)
      case status
      when 'pending'
        'secondary'
      when 'in_progress'
        'primary'
      when 'completed'
        'success'
      when 'failed'
        'danger'
      else
        'secondary'
      end
    end
  end
end

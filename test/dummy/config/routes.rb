Rails.application.routes.draw do
  mount SolidBackup::Engine => "/solid_backup"
end

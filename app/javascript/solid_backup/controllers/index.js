import { application } from "controllers/application"

import BackupController from "./backup_controller"
application.register("backup", BackupController)
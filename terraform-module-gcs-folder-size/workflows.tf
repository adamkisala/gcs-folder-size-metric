/*
 Copyright 2023 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

resource "google_project_service" "workflows_api" {
  project            = var.workflow_deployment_project
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "gcs_folder_size" {
  account_id   = "gcs-folder-size-workflow"
  display_name = "Service Account for the gcs-folder-size workfow"
  project      = var.workflow_deployment_project
}

resource "google_workflows_workflow" "gcs_folder_size" {
  depends_on = [google_project_service.workflows_api]

  name            = "gcs-folder-size"
  region          = var.workflow_deployment_region
  description     = "Workflow that monitors specified GCS folders for their size"
  service_account = google_service_account.gcs_folder_size.id
  project         = var.workflow_deployment_project

  source_contents = file("${path.module}/../workflow/gcs-folder-size-metric.yaml")
}

output "gcs_folder_size_workflow" {
  value = google_service_account.gcs_folder_size
}

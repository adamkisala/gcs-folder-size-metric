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


resource "google_service_account" "gcs_folder_size_workflow_invoker" {
  account_id   = "gcs-folder-size-wf-invoker"
  display_name = "Service Account for Cloud Scheduler to invoke the gcs-folder-size Cloud Workflow"
  project      = var.workflow_deployment_project
}

resource "google_project_service" "cloud_scheduler" {
  service            = "cloudscheduler.googleapis.com"
  project            = var.workflow_deployment_project
  disable_on_destroy = false
}

resource "google_cloud_scheduler_job" "gcs_folder_size_workflow_invoker" {
  depends_on = [google_project_service.cloud_scheduler]

  name        = "gcs-folder-size-workflow-invoker"
  description = "Cloud Scheduler Invoker for the gcs-folder-size Workflow"
  schedule    = var.gcs_folder_size_polling_period
  project     = var.workflow_deployment_project
  region      = var.workflow_deployment_region

  paused = false

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${google_workflows_workflow.gcs_folder_size.project}/locations/${google_workflows_workflow.gcs_folder_size.region}/workflows/${google_workflows_workflow.gcs_folder_size.name}/executions"
    body = base64encode(jsonencode({
      argument = jsonencode({
        targets : var.monitored_projects_buckets_and_paths,
        config = {
          "metricProject" : var.metrics_project == "" ? null : var.metrics_project,
        }
      })
      "callLogLevel" : "CALL_LOG_LEVEL_UNSPECIFIED"
    }))

    oauth_token {
      service_account_email = google_service_account.gcs_folder_size_workflow_invoker.email
    }
  }
}

output "gcs_folder_size_workflow_invoker_service_account" {
  value = google_service_account.gcs_folder_size_workflow_invoker
}

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


resource "google_project_service" "gcs_folder_size_monitoring_api" {
  project            = var.metrics_project
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false

}

resource "google_monitoring_metric_descriptor" "gcs_folder_size" {
  depends_on = [google_project_service.gcs_folder_size_monitoring_api]

  description  = "GCS folder size bytes"
  display_name = "GCS folder size bytes"
  type         = "custom.googleapis.com/storage/folder_size_bytes"
  metric_kind  = "GAUGE"
  value_type   = "INT64"
  project      = var.metrics_project

  labels {
    key         = "bucket"
    value_type  = "STRING"
    description = "The bucket being monitored"
  }

  labels {
    key         = "path"
    value_type  = "STRING"
    description = "The path being monitored"
  }

  labels {
    key         = "project"
    value_type  = "STRING"
    description = "The project where bucket is located"
  }
}

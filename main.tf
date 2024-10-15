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

module "gcs-folder-size" {
  source = "terraform-module-gcs-folder-size"

  # These variables determine where the Workflow itself is deployed.
  # A Service Account is also created in this project - no permissions
  # are granted to this service account by default
  workflow_deployment_project = "bigquery-job-alerting"
  workflow_deployment_region  = "europe-west2"

  # map(map(list(string))) of projects, buckets and paths to monitor for size changes
  monitored_projects_buckets_and_paths = {
    "my-custom-project-for-dev": {
      "some-storage-bucket-name": [
        "lets_monitor_this_folder",
        "also_this_folder/but_only_this_subfolder"
      ]
    }
  }

  # The project to store all metrics in
  metrics_project = ""

  # How often should a query be made for path sizes? This should be in Crontab format and
  # defaults to every 5 minutes
  gcs_folder_size_polling_period = "*/5 * * * *"
}

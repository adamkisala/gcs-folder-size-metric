# gcs-folder-size-metric

## Overview

This Workflow can handle monitoring specified GCS folders size in multiple projects, each of which can be easily configured.

Once deployed, this Workflow exports a custom GAUGE metric `custom.googleapis.com/storage/folder_size_bytes` labelled with
the project ID, bucket name and folder name with the size of the folder in bytes.

You are then able to use the standard Google Cloud Monitoring tool set such as alerting, and dashboarding to monitor these jobs.

## How it works

The Workflow is invoked by Cloud Scheduler, by default it will be invoked every 5 minutes (but this is configurable).

Cloud Scheduler invokes the Workflow with a payload containing information on the project ID's, 
and GCS folders to monitor for size, alongside some other configuration.

An example of the payload is shown below:

```
{
  "config": {
    "metricProject": "my-custom-monitoring-project-id"
  },
  "targets": {
    "my-custom-project-for-dev": {
      "some-storage-bucket-name": [
        "lets_monitor_this_folder",
        "also_this_folder/but_only_this_subfolder"
      ]
    }
  }
}
```

## Permissions

No permissions are handled automatically by Terraform for this Workflow. The following permissions are required:

1. `roles/storage.objectViewer` - Required to list objects in the specified GCS folders.

The workflow performs only one api call: `googleapis.storage.v1.objects.list`  to list objects in the specified GCS folders.

## Deployment

All of the configuration and deployment of this Workflow is handled automatically using Terraform.

You can import the module in this repository into to an existing Terraform configuration, or define it in a standalone configuration.

The configuration variables are documented inline below:

```
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
```

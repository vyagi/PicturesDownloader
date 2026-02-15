locals {
  function_app_api_name        = "${var.lab_name}api${var.album_number}"
  function_app_downloader_name = "${var.lab_name}downloader${var.album_number}"

  technical_storage_name = "${var.lab_name}techsa${var.album_number}"
  data_storage_name      = "${var.lab_name}sa${var.album_number}"

  service_plan_name = "faserviceplan"
  service_bus_name  = "${var.lab_name}sb${var.album_number}"
}


module "create_fs" {
  source      = "../../firestore_database"
  project     = "my-project-id"
  name        = "ahmed"
  location_id = "nam5"
  type        = "DATASTORE_MODE"
}

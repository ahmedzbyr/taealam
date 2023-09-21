resource "google_bigquery_table" "my-table" {
  project    = "my-project-id"
  dataset_id = "my-dataset"
  table_id   = "your_table_id"

  time_partitioning {
    type = "DAY"
  }

  clustering = ["customer_id"]

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "date",
    "type": "DATETIME",
    "mode": "NULLABLE",
    "description": "Created Date"
  },
  {
    "name": "customer_name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Name of the cluster"
  },
  {
    "name": "state",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "State where he lives"
  },
  {
    "name": "customer_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "customer_id "
  },  
  {
    "name": "Address",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Address"
  }  
]
EOF

}

bq extract --location=us-east1 \
--destination_format CSV \
--field_delimiter "," \
--print_header=true \
project_id:dataset.table \
gs://bucket/filename.csv
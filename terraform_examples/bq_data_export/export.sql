DECLARE backup_date DATE DEFAULT DATE_SUB(@run_date, INTERVAL 1 day);

EXPORT DATA
  OPTIONS ( uri = CONCAT('gs://my-bucket/', CAST(backup_date AS STRING), '/*.parquet'),
    format='PARQUET',
    compression='SNAPPY',
    overwrite=FALSE ) AS
SELECT
  *
FROM
  `my-project.my-dataset.my-table`
WHERE
  DATE(timestamp) = backup_date
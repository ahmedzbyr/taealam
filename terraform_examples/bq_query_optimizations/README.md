Google BigQuery is a powerful and cost-effective data warehouse that enables you to analyze massive datasets quickly. However, to get the most out of BigQuery while keeping your costs in check, it's essential to optimize your queries. Optimized queries not only improve performance but also reduce the amount of data processed, resulting in significant cost savings. Here are ten tips to help you optimize your queries and save on BigQuery costs:

## 1. Use the `LIMIT` Clause

When you're testing or debugging queries, consider using the `LIMIT` clause. This restricts the number of rows returned by your query, preventing accidental large result sets that can consume unnecessary resources. It's a helpful practice during query development.

```sql
SELECT *
FROM `your_project_id.your_dataset_id.your_table_id`
LIMIT 10;
```

## 2. Choose the Right Data Partitioning

If your dataset contains time-series data, take advantage of data partitioning by date or timestamp. Partitioning allows BigQuery to skip scanning unnecessary partitions when querying, reducing data processing costs significantly. Proper partitioning can lead to substantial performance gains and cost reductions.

Assuming your table is partitioned by the `date` column [Check terraform example below in 3]:

```sql
-- Query data for a specific date range, skipping unnecessary partitions.
SELECT *
FROM `your_project_id.your_dataset_id.your_table_id`
WHERE date >= '2023-01-01' AND date < '2023-02-01';
```

## 3. Use Clustered Tables

For large datasets, consider clustering tables based on columns frequently used in your queries. Clustering physically organizes the data within the table, optimizing query performance by reducing the amount of data scanned. This is particularly effective when dealing with JOIN operations.

Creating a table with clustering.

```hcl
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
```

Assuming you have a large table and you cluster it by the `customer_id` column:

```sql
-- Query data from a clustered table.
SELECT *
FROM `your_project_id.your_dataset_id.your_table_id`
WHERE customer_id = '12345';
```

## 4. Filter Rows Early

To minimize data processing costs, apply filtering conditions as early as possible in your query. Use the `WHERE` clause to filter data before performing any joins or transformations. Filtering early reduces the volume of data read, leading to faster query execution.

```sql
SELECT my-col1, mycol10, mycol13
FROM `your_project_id.your_dataset_id.your_table_id`
WHERE date >= '2023-01-01' AND date < '2023-02-01';
```

## 5. Avoid Using `SELECT *`

Instead of selecting all columns using `SELECT *`, explicitly list only the columns you need in your query. This practice minimizes data transfer and processing overhead, improving query performance and reducing costs.

```sql
SELECT column1, column2, column3
FROM `your_project_id.your_dataset_id.your_table_id`;
```

## 6. Use Cached Queries

BigQuery caches the results of recently executed queries. If your data is relatively static or doesn't change frequently, leverage **query caching** to save on processing costs. Cached results are served quickly, reducing the need for reprocessing.

More details can be found on the [offical documentation](https://cloud.google.com/bigquery/docs/cached-results).

In BigQuery, query results are written to a table, which can fall into one of two categories: a destination table explicitly specified by the user or a temporary cached results table. These temporary, cached results tables are unique to each user and project. Temporary tables do not incur any storage costs. However, if you opt to write query results to a permanent table, you will be billed for storing that data.

It's important to note that all query results, whether generated by interactive or batch queries, are initially stored in temporary tables. These temporary tables persist for approximately 24 hours, although there may be some exceptions to this rule.

## 7. Leverage BI Engine

If you're using BigQuery for interactive dashboards and reports like `looker`, `Data Studio` etc, consider enabling BigQuery BI Engine. BI Engine provides in-memory caching to accelerate query performance. It's particularly useful for scenarios where sub-second query response times are essential.

## 8. Optimize JOINs

Be mindful of how you use JOIN operations in your queries. Whenever possible, use INNER JOINs to eliminate unnecessary rows early in the query execution process. For large tables, consider denormalizing data or using materialized views to reduce JOIN complexity and enhance performance.

```sql
-- Use INNER JOIN to combine two tables based on a shared column.
SELECT orders.order_id, customers.customer_name
FROM `your_project_id.your_dataset_id.orders` AS orders
INNER JOIN `your_project_id.your_dataset_id.customers` AS customers
ON orders.customer_id = customers.customer_id;
```

## 9. Monitor Query Execution Times

Regularly monitor query execution times using BigQuery's query history and the Query Execution Time field. Identify slow-running queries and optimize them to reduce both execution time and associated costs. Query optimization is an ongoing process.

More information can be found the [offical documentation](https://cloud.google.com/bigquery/docs/monitoring)

## 10. Use Parameterized Queries

If you find yourself running similar queries with different parameters, consider using parameterized queries. Parameterization allows you to reuse cached results and reduce redundant processing, resulting in cost savings and improved query performance.

```sql
DECLARE start_date DATE;
DECLARE end_date DATE;

SET (start_date, end_date) = ('2023-01-01', '2023-02-01');

SELECT *
FROM `your_project_id.your_dataset_id.your_table_id`
WHERE date BETWEEN start_date AND end_date;
```

In conclusion, query optimization in BigQuery is essential for achieving both performance and cost savings. By following these ten tips and continuously refining your queries based on changing data patterns and requirements, you can harness the full potential of BigQuery while keeping your costs under control.
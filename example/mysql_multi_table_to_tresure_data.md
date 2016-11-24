## case study

It is a guide to replicate multiple mysql table to treasure data.

## configuration

```
<source>
  type mysql_appender_multi

  # Set connection settings for replicate source.
  host localhost
  username your_mysql_user
  password your_mysql_password
  database myweb

  interval 1m  # execute query interval (default: 1m)
  yaml_path "in_tables.yml"
</source>

<match appender_multi.*.*>
  type tdlog
  endpoint your_td_endpoint
  apikey your_td_apikey

  auto_create_table
  buffer_type file
  buffer_path /var/log/td-agent/buffer/td
  flush_interval 1m
  use_ssl true
  num_threads 8

  <secondary>
    @type file
    path /var/log/td-agent/failed_records
    compress gzip
  </secondary>
</match>
```

Sample "in_tables.yml" is below.

```
- table_name: test_tbl1
  primary_key: id
  time_column: created_at
  limit: 1000
  columns:
    - id
    - column1
    - column2
  last_id: -1
  buffer: 10   # last 10 records don't append (default 0).
  td_database: sample_datasets

- table_name: test_tbl2
  primary_key: id
  time_column: created_at
  limit: 1000
  columns:
    - id
    - column1
    - column2
  last_id: -1
  buffer: 10   # last 10 records don't append (default 0).
  td_database: sample_datasets
```
## case study

It is a guide to replicate multiple mysql table to treasure data.

## environment variables

Please set environment variables.

```
TD_APIKEY    xxxxxxxx  # Treasure data API key.
TD_ENDPOINT  api.treasuredata.com  # Treasure data API endpoint. e.g. "api.treasuredata.com".
TD_DATABASE  sample_db # Treasure data database name.
```

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
  primary_key: id  # incremental id
  time_column: created_at  # assigned to td's time column
  limit: 1000
  columns:
    - id
    - column1
    - column2
    - created_at
  delay: 10s
  entry_time: created_at  # if this column is greater (now - delay), wait insert.

- table_name: test_tbl2
  primary_key: id  # incremental id
  time_column: created_at  # assigned to td's time column
  limit: 1000
  columns:
    - id
    - column1
    - column2
    - created_at
  delay: 10s
  entry_time: created_at  # if this column is greater (now - delay), wait insert.
```

```
select id, column1, column2, created_ad from test_tbl1 where id > {last_id} limit 1000
```

```
select id, column1, column2, created_ad from test_tbl2 where id > {last_id} limit 1000
```

run query in each syncronize loops.

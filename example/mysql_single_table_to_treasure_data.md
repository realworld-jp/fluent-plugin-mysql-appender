## case study

It is a guide to replicate single mysql table to treasure data.

## configuration

```
<source>
  type mysql_appender

  # Set connection settings for replicate source.
  host localhost
  username your_mysql_user
  password your_mysql_password
  database myweb

  # Set replicate query configuration.
  query SELECT id, text, updated_at from search_test;
  primary_key id # specify incremental unique key (default: id)
  interval 1m  # execute query interval (default: 1m)

  # Format output tag for each events.
  tag appender.myweb.your_td_database.your_td_table

  time_column created_at # specify TIME column.
  limit   1000 # query limit
  last_id -1   # specify primary_key start
  buffer  10   # last 10 records don't append (default 0).
</source>

<match appender.*.*>
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


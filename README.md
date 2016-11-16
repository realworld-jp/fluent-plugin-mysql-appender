# fluent-plugin-mysql-appender

## Overview

Fluentd input plugin to track insert event only from MySQL database server.
Simple incremental id's insert.

## Installation

install with gem or fluent-gem command as:

`````
# for system installed fluentd
$ gem install fluent-plugin-mysql-appender

# for td-agent2
$ td-agent-gem install fluent-plugin-mysql-appender
`````

## Included plugins

* Input Plugin: mysql_appender
* Input Plugin: mysql_appender_multi

## Output example

It is a example when detecting insert events.

### sample query

`````
$ mysql -e "create database myweb"
$ mysql myweb -e "create table search_test(id int auto_increment, text text, PRIMARY KEY (id))"
$ sleep 10
$ mysql myweb -e "insert into search_test(text) values('aaa')"
`````

### result

`````
$ tail -f /var/log/td-agent/td-agent.log
2013-11-25 18:22:25 +0900 appender.myweb.search_test: {"id":"1","text":"aaa"}
`````

mysql query log is below

`````
$ tail -f /var/log/mysql/general-query.log
161108 19:25:52        4 Connect    root@localhost on myweb
            4 Query    SELECT id, text FROM search_test where id > -1 order by id asc
            4 Quit
161108 19:26:02        5 Connect    root@localhost on myweb
            4 Query    SELECT id, text FROM search_test where id > 1 order by id asc
            4 Quit
`````

## Tutorial

### mysql_appender

see example/mysql_single_table_to_tresure_data.md.

**Features**

* Table (or view table) synchronization supported.
* Replicate small record under a millons table.

### mysql_appender_multi

see example/mysql_multi_table_to_tresure_data.md.

**Features**

* table (or view table) synchronization supported.
* Multiple table synchronization supported and its DSN stored in yaml file.

## TODO

Pull requests are very welcome like below!!

* more documents
* more tests.


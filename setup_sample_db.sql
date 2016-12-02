create database sample_db;
create table test_tbl1 (
    id int auto_increment,
    column1 varchar(10),
    column2 varchar(10),
    created_at timestamp default current_timestamp,
    primary key(id)
);

insert into test_tbl1 (column1, column2) value ('1','2');
insert into test_tbl1 (column1, column2) value ('3','4');
insert into test_tbl1 (column1, column2) value ('5','6');
insert into test_tbl1 (column1, column2) value ('7','8');

create table test_tbl2 (
    id int auto_increment,
    column1 varchar(10),
    column2 varchar(10),
    created_at timestamp default current_timestamp,
    primary key(id)
);

insert into test_tbl2 (column1, column2) value ('A','E');
insert into test_tbl2 (column1, column2) value ('B','F');
insert into test_tbl2 (column1, column2) value ('C','G');
insert into test_tbl2 (column1, column2) value ('D','H');




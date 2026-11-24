-- version 8.x
-- show version(); 
show databases; 
-- creating the Database in localhost instance
create database sample_db_nov_2026;

-- select this DB for further operation -- IMP 
use sample_db_nov_2026; -- henceforth all the queries will refer to this DB.
 
/*
Engines
- MyISAM
- InnoDB --- transactions, procedues, triggers -- DEFAULT
*/

show engines; 

-- creating a sample table 

create table sample_table(
id int primary key auto_increment,
name varchar(255) not null,
city varchar(255),
age int,
points double default 10
);

describe sample_table; 

-- ADD a new column to the table 

alter table sample_table
ADD column rating double default 1; 

-- Modify the existing column to add a constraint
alter table sample_table 
MODIFY column city varchar(255) NOT NULL;

-- Rename the column (points --> credits)
ALTER table sample_table
RENAME column points to credits; 

-- change the column name and constraints at a same time (MODIFY + RENAME)
Alter table sample_table
CHANGE column city city_name varchar(100); 

-- DROP the column (you do loose the data as well)
ALTER table sample_table
DROP column rating;

-- INCREMENTAL PROJECT -- lms_db_nov_2026
/*
SQL:
select <attributes>   <-- Projection  mandatory
from <table(s)-name> <-- mandatory
where <condition> <-- optional clause
group by <grouping attribute> <-- optional
having <condition on grouping Fn> <-- optional
order by <attribute> ASC |DESC <-- optional
limit <skip> <-- optional
*/
use lms_db_nov_2026;
/* Insertion */
insert into learner (name, user_id,contact_id,address_id) 
values ("Harry Potter", 1, 1,1);

insert into user(username,password,role) 
values ("harry", "harry@123", "LEARNER");
 
insert into contact(primary_contact,  main_email)
values("123654756", "harry@gmail.com");

insert into address(city) value('london');

-- Refrential Integrity of Foreign Keys
insert into learner (name, user_id,contact_id,address_id) 
values ("Harry Potter", 2, 1,1);
/*
Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails 
(`lms_db_nov_2026`.`learner`, CONSTRAINT `fk_learner_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`))
*/

-- Reuse address - it works right now - we need to fix this later 
 insert into learner (name, user_id,contact_id,address_id) 
values ("Ronald Weasley", 1, 1,1);
















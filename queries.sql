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

-- alter the table settings to keep user_id as unique and let contact and address be shared as they are
alter table learner 
DROP primary key,
ADD primary key (id),
ADD UNIQUE (user_id);

-- making address_id FK as nullable so we can delete that in isolation 

alter table learner 
MODIFY column address_id INT NULL; 

delete from address where id=1; 

alter table learner
drop foreign key fk_learner_address1;

alter table learner 
ADD CONSTRAINT `fk_learner_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `lms_db_nov_2026`.`address` (`id`)
    ON DELETE SET NULL;

delete from address where id=1; 

/*
In earlier example, when address(parent) is deleted, child was not deleted as ON delete was 'SET NULL'. 
In this example, I want to delete the child(learner) when parent(user) is deleted. 
*/
-- step 1
alter table learner 
drop foreign key fk_learner_user;

-- step 2
alter table learner
ADD CONSTRAINT `fk_learner_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `lms_db_nov_2026`.`user` (`id`)
    ON DELETE CASCADE;
     
-- step 3
delete from user where id=1; 

/* user gets deleted, learner gets deleted. s it is cascade */

/*
Update Op: here we can update the attribute values of all rows except the primary key
So the child table never has a problem with parent row getting updated

For ex, updating contact table record does not bother connected learner record. 
*/

update contact
 SET alternate_contact = '7856787456'
where id=1;

-- in case where a completely new record is created in contact (parent) then foreign key in child table can be updated but this approach 
-- is never appreciated. 

insert into learner (name, user_id,contact_id) 
values ("Harry Potter", 2, 1);

-- new contact 
insert into contact(primary_contact,  main_email)
values("435345656", "test@gmail.com");

-- update learner and assign the new contact to it 
update learner 
set contact_id = 2
where id=7; 

-- update goes thru and now the learner points to new contact
/* before update of contact 
+----+--------------+---------+------------+------------+
| id | name         | user_id | contact_id | address_id |
+----+--------------+---------+------------+------------+
|  7 | Harry Potter |       2 |          1 |       NULL |
+----+--------------+---------+------------+------------+
*/

/* After update of contact 
mysql> select * from learner;
+----+--------------+---------+------------+------------+
| id | name         | user_id | contact_id | address_id |
+----+--------------+---------+------------+------------+
|  7 | Harry Potter |       2 |          2 |       NULL |
+----+--------------+---------+------------+------------+
*/

-- the earlier contact record(id =1) has no use as it is being replaced but still is in the table and its called as ORPHAN record. 
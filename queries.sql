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

-- select op
-- Query to fetch all learners 
/*
When your fetch child record, U must also fetch the corresponding record of the Parent tables. 
learner has 3 parent tables: user, contact, address. 
2 of these are NOT NULL and address can be NULL. 
*/
select * from learner; -- this give me learner details with FKs which is not of much help 

/*
3 ways of combining tables (Parent child relationship )
1. Manual Mapping 
2. Joins 
3. Nested Queries (Sub-Query)
*/

 -- Manual Mapping 
select l.id,l.name,c.primary_contact, c.main_email, u.username, u.is_active , a.city
from learner l, contact c, user u , address a
where l.user_id = u.id AND l.contact_id = c.id AND l.address_id = a.id;
-- the issue with manual mapping is that if any of the where clause conditions fail, we loose entire info (it displays nothing)

-- joins 
/*
1. JOIN (Inner JOIN)
2. LEFT JOIN 
*/

select l.id,l.name,c.primary_contact, c.main_email, u.username, u.is_active , a.city
from learner l 
	JOIN user u ON l.user_id = u.id 
    JOIN contact c ON l.contact_id = c.id 
    JOIN address a ON l.address_id = a.id; 

-- in the above INNER JOIN query, since address a is NULL there is nothing to JOIN 
-- and hence we loose all records that have no address. 

select l.id,l.name,c.primary_contact, c.main_email, u.username, u.is_active , coalesce(a.city , 'Not Provided') as city
from learner l 
	JOIN user u ON l.user_id = u.id 
    JOIN contact c ON l.contact_id = c.id 
    LEFT JOIN address a ON l.address_id = a.id;  -- JOIN address if you can , else ignore it 


-- giving proper info to app e.g. is_active 
select l.id,l.name,c.primary_contact, c.main_email, u.username,
 case u.is_active 
	 when 1 THEN 'ENABLED' 
	 when 0 THEN 'DISABLED'
	 ELSE 'UNKNOWN' 
 END 
 as learner_status, 
 coalesce(a.city , 'Not Provided') as city
from learner l 
	JOIN user u ON l.user_id = u.id 
    JOIN contact c ON l.contact_id = c.id 
    LEFT JOIN address a ON l.address_id = a.id;


-- inserting records in course table but since it has instructor_id and department_id as foreign_keys, we start from there
-- but instructor also has FK from user, contact and address tables so lets start from there. 

insert into user (username, password, role) 
values ('Albus Dumbledore', "albus@123", "INSTRUCTOR"); 
 update user set username = 'albus' where id = 3;
insert into contact(primary_contact,  main_email)
values("85968978567", "albus@gmail.com");

insert into address(city, pincode) values ('MUMBAI', '400092');

insert into instructor(name, salary, contact_id, user_id, address_id) 
values ("Albus Dumbledore", "250000", 3,3,2); 

insert into department(name) values ('programming'),('product management');  -- multiple inserts 

insert into course (name, fee, instructor_id, department_id) 
values ('SQL programming', 3500, 1, 1);

-- Query to fetch info about the course 
select c.id as course_id,
c.name as course_name,
c.fee,
i.name as instructor_name,
d.name as department_name
from course c 
JOIN instructor i ON c.instructor_id = i.id 
JOIN department d ON c.department_id = d.id;  

/*
+-----------+-----------------+------+------------------+-----------------+
| course_id | course_name     | fee  | instructor_name  | department_name |
+-----------+-----------------+------+------------------+-----------------+
|         1 | SQL programming | 3500 | Albus Dumbledore | programming     |
+-----------+-----------------+------+------------------+-----------------+
*/

-- Group By 

-- display all course info of instructor with id= 1. 

select c.*, i.name 
from instructor i 
JOIN course c ON i.id = c.instructor_id 
where i.id=1;


insert into user (username, password, role) 
values ('severus', "severus@123", "INSTRUCTOR"); 
 
 insert into contact(primary_contact,  main_email)
values("6656565656", "severus@gmail.com");

insert into address(city, pincode) values ('LONDON', 'TW31SE');

insert into instructor(name, salary, contact_id, user_id, address_id) 
values ("Severus Snape", "230000", 4,4,3); 


insert into course (name, fee, instructor_id, department_id) 
values ('JAVA programming', 6500, 1, 1);


insert into course (name, fee, instructor_id, department_id) 
values ('SPRING Framework', 8500, 2, 1);

-- display number of courses taught by each/all instructors

/*
Intr_name			Number_of_courses
Albus Dumbledore		2
Severus Snape			1	
*/

select i.name, count(c.id) as 'Number of courses'
from instructor i 
JOIN course c ON i.id = c.instructor_id
group by i.id, i.name;

/*
i.id = 1 i.name = 'Albus Dumbledore' -- group 1
 1 | Albus Dumbledore | 250000 |          3 |       3 |          2 |  1 | SQL programming  | 3500 |             1 |             1 |
 1 | Albus Dumbledore | 250000 |          3 |       3 |          2 |  2 | JAVA programming | 6500 |             1 |             1 |

i.id = 2 i.name = 'Severus Snape'  --group 2
2 | Severus Snape    | 230000 |          4 |       4 |          3 |  3 | SPRING Framework | 8500 |             2 |             1 |
*/

/* Aggregate / Grouping Functions 
1. count
2. avg
3. max
4. min
5. sum
*/

-- compute the avg salary of instructors for each department. 

/*
dept_name	 Avg_salary
programming		2L
management		1.8L
*/
-- record 1
insert into user (username, password, role) 
values ('jack', "jack@123", "INSTRUCTOR"); 
 
 insert into contact(primary_contact,  main_email)
values("453534535345", "jack@gmail.com");

insert into address(city, pincode) values ('NEW YORK', 'NY5 6yth');

insert into instructor(name, salary, contact_id, user_id, address_id) 
values ("Jack Reacher", "270000", 5,5,4); 

-- record 2
insert into user (username, password, role) 
values ('simon', "simon@123", "INSTRUCTOR"); 
 
 insert into contact(primary_contact,  main_email)
values("78785657567", "simon@gmail.com");

insert into address(city, pincode) values ('CHENNAI', '556098');

insert into instructor(name, salary, contact_id, user_id, address_id) 
values ("Simon Orielly", "180000", 6,6,5); 


insert into course (name, fee, instructor_id, department_id) 
values ('Product Management', 9500, 3, 2);


insert into course (name, fee, instructor_id, department_id) 
values ('ITA cert 1', 2345, 4, 2);

-- compute the avg salary of instructors for each department. 

select d.name, avg(i.salary) as 'AVG Salary'
from instructor i 
JOIN course c ON i.id = c.instructor_id 
JOIN department d ON c.department_id = d.id
group by d.name;

/*
d.name = programming
1	Albus Dumbledore	250000	3	3	2	1	SQL programming	3500	1	1	1
1	Albus Dumbledore	250000	3	3	2	2	JAVA programming	6500	1	1	1
2	Severus Snape	230000	4	4	3	3	SPRING Framework	8500	2	1	1
d.name = product management
3	Jack Reacher	270000	5	5	4	4	Product Management	9500	3	2	2
4	Simon Orielly	180000	6	6	5	5	ITA cert 1	2345	4	2	2

programming	243333.33333333334
product management	225000
*/


-- Display total enrolled learners for each course. 
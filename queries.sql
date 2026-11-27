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

-- learner insertion
/* Insertion */
insert into learner (name, user_id,contact_id,address_id) 
values ("draco malfoy", 9, 9,8);

insert into user(username,password,role) 
values ("draco", "draco@123", "LEARNER");
 
insert into contact(primary_contact,  main_email)
values("547567567567", "draco@gmail.com");

insert into address(city) value('london');

-- assign course to learner 
insert into learner_course(learner_id, course_id, date_of_enroll, amount_paid, coupon, discount )
values (7,1, now(), 3500, NULL, 0),
(7,2, now(), 6000, 'OFF500', 500),
(8,1,now(),3500, null, 0),
(9,1,now(),3500, null, 0),
(9,2,now(),6000, 'OFF500', 500),
(9,3,now(),7500, 'OFF1000', 1000),
(10,4,now(),9500, null, 0),
(9,5,now(),2000, 'OFF345', 345);

-- Display total enrolled learners for each course. 

select c.name as 'Course',count(l.id) as 'Learners'
from course c  
JOIN learner_course lc ON c.id = lc.course_id 
JOIN learner l ON l.id = lc.learner_id
group by c.id,c.name;

-- Display total enrolled learners for each course. only display courses which have atleast 2 students , 
-- order in ASC order

select c.name as 'course',count(l.id) as 'learners'
from course c  
JOIN learner_course lc ON c.id = lc.course_id 
JOIN learner l ON l.id = lc.learner_id
group by c.id,c.name
having learners >= 1   -- having is used specifically to write condition on grouing functions 
order by learners ASC  -- by default, ordering is ASC 
limit 10 -- it limits the result set to only 2 records 
;
  
insert into course (name, fee, instructor_id, department_id) 
values ('Scrum A-Z', 6000, 3, 2);

select c.name as 'course',count(l.id) as 'learners'
from course c  
LEFT JOIN learner_course lc ON c.id = lc.course_id 
LEFT JOIN learner l ON l.id = lc.learner_id
group by c.id,c.name
;
/*
SQL programming		3
JAVA programming	2
SPRING Framework	1
Product Management	1
ITA cert 1			1
Scrum A-Z			0
*/

select c.name as 'course',count(l.id) as 'learners'
from learner l  
RIGHT JOIN learner_course lc ON l.id = lc.learner_id
RIGHT JOIN course c ON c.id = lc.course_id
group by c.id,c.name
;

-- LEFT and RIGHT are same, except it depends on the sequence of join. 

insert into track(name) values ('Java Programming'), ('Product Mgmt'), ('App Development');

insert into course_track(course_id, track_id) values (1,1),(2,1),(2,3),(3,3),(4,2),(5,2);

-- lets add a lead_id column in instructor table and referece it to the same table instructor as self join 

alter table instructor 
	ADD column lead_id INT NULL,
	ADD constraint fk_instructor_lead
		FOREIGN KEY (lead_id)
        REFERENCES instructor(id);

update instructor SET lead_id = 1 where id = 2; 
update instructor SET lead_id = 2 where id = 3; 
update instructor SET lead_id = 2 where id = 4; 

-- self join: display the names of instructors along with their leads. 

select i.name as Instructor, coalesce(l.name, "No Lead") as 'Lead_name'
from instructor i  -- ref 1 : PK: id
LEFT JOIN instructor l  -- ref 2 : FK : lead_id
ON l.id = i.lead_id;
/*
Albus Dumbledore	No Lead
Severus Snape	Albus Dumbledore
Jack Reacher	Severus Snape
Simon Orielly	Severus Snape
*/

-- count number of instructors working directly under each lead 

select l.name, count(i.id) as 'Number_of_Instrcutors'
from instructor i 
JOIN instructor l ON l.id = i.lead_id
group by l.id, l.name; 

/*
Albus Dumbledore	1
Severus Snape	2
*/

-- Display instructors that teach atleast one course. 

select distinct i.name   -- distinct does not prevent JOIN , it only removes duplicates after the join has happend
from instructor i JOIN course c ON i.id = c.instructor_id;

-- in the above query, a full join happens, and then for ignoring duplicates we use distinct. 
-- in a DB where we have millions of records, this approach of letting a full join happen is never going to work 

-- do a semi join: JOIN after the condition is true 

select i.name 
from instructor i 
where EXISTS (select i.name from instructor i JOIN course c ON i.id = c.instructor_id);

-- EXISTS only needs 1 match, so if an instructor say albus comes up due to 1st course connection, the rest
-- of the connections of albus teaching other courses is NOT done. 

-- if the condition WHERE EXISTS is true even once for the first time check, move on to second instructor 

-- display department tht has atleast one instructor 
select d.name
from department d 
where EXISTS (select 1 from department d 
JOIN course c ON d.id = c.department_id 
JOIN instructor i ON i.id = c.instructor_id);
 
-- Nested Query / Subquery 
-- You write sub query, when you need something pre-calculated. 
-- Never replace normal join queries with sub-queries. 

-- Display all instructors whose salary is greater than average salary of instructors working in programming department
-- Fan-out issue


select i.name -- we display those instructors whose salary is greater than avg salary computed
from instructor i
where i.salary > (select i.name from instructor i   -- once we get instructors from programming department, we compute their avg(salary). here we avoid duplicates
					WHERE EXISTS (select i.name from instructor i  
								JOIN course c ON i.id = c.instructor_id
								JOIN department d ON c.department_id = d.id 
								where d.name='programming')); -- where exits is used to avoid fan-out problem i.e. duplicate records getting added for computing avg 

 -- where exits is used to avoid fan-out problem i.e. duplicate records getting added for computing avg 
 -- once we get instructors from programming department, we compute their avg(salary). here we avoid duplicates
 -- we display those instructors whose salary is greater than avg salary computed


-- step 1: fetch all instructors that are teaching in department=programming via course 

select i.id from instructor i  
JOIN course c ON i.id = c.instructor_id
JOIN department d ON c.department_id = d.id 
where d.name='programming';

-- o/p: 1 1 2  

-- step 2 - to fix this we use IN
select i.name
from instructor i
where i.salary >
				(select avg(i.salary)
				from instructor i
				WHERE i.id IN (select i.id from instructor i  
								JOIN course c ON i.id = c.instructor_id
								JOIN department d ON c.department_id = d.id 
								where d.name='programming'));
-- Nested - Sub-Queries 
/*
IN 
where exists 
ALL 
ANY
=
*/

-- display instructors earning more than ALL the instructor working in 'programming' department 
select i.name
from instructor i 
where i.salary > ALL (select i.salary from instructor i 
						JOIN course c ON i.id = c.instructor_id
						JOIN department d ON c.department_id = d.id 
						where d.name='programming');
-- we don't usually use this ALL as this is similar to using max grouping Fn 
select i.name
from instructor i 
where i.salary >  (select max(i.salary) from instructor i 
						JOIN course c ON i.id = c.instructor_id
						JOIN department d ON c.department_id = d.id 
						where d.name='programming');

-- display instructors earning more than atleast one instructor from 'product management' department 
select i.name
from instructor i 
where i.salary > ANY (select i.salary from instructor i 
						JOIN course c ON i.id = c.instructor_id
						JOIN department d ON c.department_id = d.id 
						where d.name='product management');
 -- OR                       
select i.name
from instructor i 
where i.salary >  (select min(i.salary) from instructor i 
						JOIN course c ON i.id = c.instructor_id
						JOIN department d ON c.department_id = d.id 
						where d.name='product management');
                         

-- IN 
-- display all learners living in following cities ['london', 'mumbai']

select l.name
from learner l JOIN address a ON l.address_id = a.id
where a.city IN ('london', 'mumbai');

-- using subquery 
select l.name
from learner l
where l.address_id IN (select a.id 
						from address a 
						where a.city IN ('london', 'mumbai')); 
-- 7 = [8,9,1,2]

-- display learner that have enrolled in course name as Java Programming. do this using sub query 

select l.name
from learner l
where l.id IN 
			(select lc.learner_id 
            from learner_course lc 
            where lc.course_id = (select c.id -- '=' here works because we r guarateed to get single id as c.name is unique
								  from course c 
                                   where c.name="java programming")); 

select l.name
from learner l
where l.id IN 
			(select lc.learner_id 
            from learner_course lc 
            where lc.course_id IN ( select c.id 
									from course c 
									where c.name="java programming"));

-- window functions : rank(), dense_rank(), row_number() 
/*
+----+--------------------+------+---------------+---------------+
| id | name               | fee  | instructor_id | department_id |
+----+--------------------+------+---------------+---------------+
|  1 | SQL programming    | 3500 |             1 |             1 |
|  2 | JAVA programming   | 6500 |             1 |             1 |
|  3 | SPRING Framework   | 8500 |             2 |             1 |
|  4 | Product Management | 9500 |             3 |             2 |
|  5 | ITA cert 1         | 2345 |             4 |             2 |
|  6 | Scrum A-Z          | 6000 |             3 |             2 |
+----+--------------------+------+---------------+---------------+
*/
-- display the courses and their ranks as per the fee 
select c.name, c.fee , RANK() OVER (order by fee DESC) as rnk
from course c;

/*
Product Management	9500	1
SPRING Framework	8500	2
JAVA programming	6500	3
Scrum A-Z			6500	3
SQL programming		3500	5
ITA cert 1			2345	6
*/
update course SET fee=6500 where id=6;
-- rank() skips the sequence -- above it has skipped rank 4

select c.name, c.fee , DENSE_RANK() OVER (order by fee DESC) as rnk
from course c;

/*
Product Management	9500	1
SPRING Framework	8500	2
JAVA programming	6500	3
Scrum A-Z			6500	3
SQL programming		3500	4
ITA cert 1			2345	5
*/
-- dense rank does not skip seq. 

select c.name ,
row_number() OVER (order by c.fee ASC) as row_num ,
RANK() OVER (order by fee DESC) as rnk, 
DENSE_RANK() OVER (order by fee DESC) as dense_rnk
from course c;


-- TODO: compute ranks by instructor salaries. ASC & DESC

select c.name, c.fee , c.department_id, 
DENSE_RANK() OVER (partition by c.department_id order by fee DESC) as rnk
from course c;

/*
SPRING Framework	8500	1	1
JAVA programming	6500	1	2
SQL programming		3500	1	3
Product Management	9500	2	1
Scrum A-Z			6500	2	2
ITA cert 1			2345	2	3
*/

-- Procedure 


-- think of it as a box that holds SQL query(ies)
DELIMITER $$
create procedure all_courses() 
BEGIN
	select * from course;
END;
 $$

show procedure status where db='lms_db_nov_2026';

CALL all_courses();

-- procedues can be called from Java app directly. which means, the java programmer would not know what logic is 
-- inside the procedure. 
-- it only sees theresult procedure give 
-- THIS ENSURES LOGIC SECURITY 

-- display all courses that belong to particular department 

DELIMITER $$
create procedure courses_by_dept_id(IN p_deptId INT) -- p_deptId = 1
BEGIN
	select c.id,c.name
	from course c
	where c.department_id = p_deptId;
END;
$$

call courses_by_dept_id(1);

-- Give the total fee of all courses that belong to particular track (id)

DELIMITER $$
create procedure sum_course_fee_by_track_id(IN p_trackId INT, OUT p_sum int)
BEGIN
	-- sql
	select SUM(c.fee) into p_sum
	from course c 
	JOIN course_track ct ON c.id = ct.course_id
	where ct.track_id = p_trackId;
END;
$$

drop procedure sum_course_fee_by_track_id; 

CALL sum_course_fee_by_track_id(2, @sum);
select @sum;

-- INOUT 
DELIMITER $$
create procedure sum_course_fee_by_track_id_inout(INOUT p_val INT)
BEGIN
	-- sql
	select SUM(c.fee) into p_val
	from course c 
	JOIN course_track ct ON c.id = ct.course_id
	where ct.track_id = p_val;
END;
$$
SET @val = 2;
CALL sum_course_fee_by_track_id_inout(@val);
select @val

-- create a login procedure for LMS system
-- in: username, password 
-- out: role 

DELIMITER $$
create procedure login(
IN p_username varchar(255) , 
IN p_password varchar(255), 
OUT p_role varchar(255) )

BEGIN
	DECLARE v_password varchar(255);
    DECLARE v_role varchar(255);
    DECLARE v_isactive boolean;
    
	-- sql
    select u.password, u.role, u.is_active into v_password, v_role, v_isactive
    from user u
    where u.username=p_username;
    
    -- check for validation
     
    IF v_password IS NULL OR p_password <> v_password THEN  -- v_password is the DB password, p_password is given by enduser
		SIGNAL sqlstate "45000" SET message_text="Invalid credentials"; -- throw exception
	END IF;
    
    IF v_isactive = FALSE THEN
		SIGNAL sqlstate "45000" SET message_text="User is disabled";
	END IF;
    
    SET p_role = v_role; 
END;
$$

CALL login('harry', 'harry@123', @role); -- LEARNER
select @role;

CALL login('albus', 'albus@123', @role); -- INSTRUCTOR
select @role;

CALL login('dfsdgsdfsdf', 'albus@123', @role); -- Error Code: 1644. Invalid credentials

CALL login('albus', 'albus123', @role); -- Error Code: 1644. Invalid credentials

CALL login('draco', 'draco@123', @role); -- Error Code: 1644. User is disabled

select * from user; 
delete from user where id=10;
update user SET is_active=false where id=9;
update user SET is_active=true where id between 1 and 11 ; 








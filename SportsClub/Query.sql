--List all possible combinations of courses and trainers.
SELECT c.course_name, t.tname
	FROM course c
	CROSS JOIN trainer t;

--Generate all combinations of members, courses, and target groups.
SELECT m.memname, c.course_id, t.targetgroup
	FROM member m
	CROSS JOIN course c
	CROSS JOIN targetgroup t;

--Find all possible member and device pairings, then filter those where the member has reservations.
SELECT m.memname, d.device_id
	FROM member m
	CROSS JOIN device d
	WHERE m.memname IN (SELECT memname FROM reservation);

--Generate all possible pairings between trainers, members, and devices, and filter for devices that are reserved.
SELECT t.tname, m.memname, d.device_id
	FROM trainer t
	CROSS JOIN member m
	CROSS JOIN device d
	WHERE d.device_id IN (SELECT device_id FROM reservation);

--Insert pairings of members and devices into a hypothetical device_usage table.
INSERT INTO device_usage(memname, device_id)
	SELECT m.memname, d.device_id
	FROM member m
	CROSS JOIN device d;

--List all members and their enrolled course IDs.
SELECT m.memname, e.course_id
	FROM member m
	INNER JOIN enrollment e
	ON m.memname = e.memname;

--Find all trainers and the courses they are assigned to.
SELECT t.tname, c.course_name
	FROM trainer t
	INNER JOIN course c
	ON t.tname = c.trainer;

--Find members and their parents who are also members.
SELECT m.memname, p.memname
	FROM member m
	INNER JOIN member p
	ON m.parent = p.memname;

--List all courses with their target group description.
SELECT c.course_name, tg.description
	FROM course c
	INNER JOIN targetgroup tg
	ON c.targetgroup = tg.targetgroup;

--List all members, their enrolled courses, and the trainers for those courses.
SELECT e.memname, e.course_id, c.trainer
	FROM enrollment e
	INNER JOIN course c
	ON e.course_id = c.course_id;

--Retrieve members with their parents (if available).
SELECT m.memname, p.memname
	FROM member m
	LEFT JOIN member p
	ON m.parent = p.memname;

--Find all members with their parents and the parent's parent (grandparent) names, if any.
SELECT m.memname AS member_name, p.memname AS parent, g.memname AS grandparent
	FROM member m
	LEFT JOIN member p
	ON m.parent = p.memname
	LEFT JOIN member g
	ON p.parent = g.memname;

--Retrieve all members and their parents, even if no parent is assigned.
SELECT m.memname AS members, p.memname AS parents
	FROM member m
	FULL JOIN member p
	ON m.parent = p.memname;

--Retrieve all enrollments and members, even if an enrollment is missing a member or a member has no enrollments.
SELECT m.memname, e.course_id
	FROM member m
	FULL JOIN enrollment e
	ON m.memname = e.memname;

--Retrieve all courses, trainers, and target groups, even if any of them is missing a link.
SELECT c.course_id, t.tname, tg.targetgroup
	FROM course c
	FULL JOIN trainer t
	ON c.trainer = t.tname
	FULL JOIN targetgroup tg
	ON c.targetgroup = tg.targetgroup;

--List all courses and their corresponding targetgroups.
SELECT * FROM course 
	NATURAL JOIN targetgroup;

--Write a query to combine the names of all members from the member table and 
--the names of all trainers from the trainer table. Remove duplicates.
SELECT memname FROM member
UNION 
SELECT tname FROM trainer;

--Combine the names of members who have enrolled in courses and trainers 
--who lead courses into a single list without duplicates.
SELECT m.memname 
	FROM member m
	INNER JOIN enrollment e 
	ON m.memname = e.memname
UNION
SELECT t.tname
	FROM trainer t
	INNER JOIN course c
	ON t.tname = c.trainer;

--Combine the reservation details for two time periods, such as 
--before and after a specific date, into one unified result.
SELECT * FROM reservation
	WHERE timeslot < '2024-10-14'
UNION ALL
SELECT * FROM reservation
	WHERE timeslot > '2024-10-15';

--In the member table, each member may have a parent member (e.g., a coach or a senior). 
--Write a recursive query to find all members reporting to a specific member, starting from 'lisa'.
WITH RECURSIVE child_parent(memname, birthday, parent) AS (
	SELECT memname, birthday, parent
		FROM member
		WHERE memname = 'lisa'
	UNION ALL
	SELECT m.memname, m.birthday, m.parent
		FROM member m
		INNER JOIN child_parent child
		ON child.parent = m.memname
) 
SELECT * FROM child_parent;	

--Find every member with postalcode more than 4500.
WITH upper_postalcode AS (
	SELECT memname AS memnames, postalcode AS postalcodes 
		FROM member
		WHERE postalcode > '4500'
) 
SELECT m.memname, m.postalcode
	FROM member m
	INNER JOIN upper_postalcode u
	ON m.memname = u.memnames;

--This query returns the names of trainers, their license status
--and the areas they manage, where the trainer has a valid license.
SELECT t.tname AS trainer, t.license, a.area
	FROM trainer t
	INNER JOIN area a
	ON t.tname = a.manager
	WHERE t.license = 'true';

--Find the member with maximum birthday.
WITH max_birth AS (
	SELECT MAX(birthday) AS max_bd
		FROM member
)
SELECT m.memname, m.birthday
	FROM member m
	INNER JOIN max_birth x
	ON m.birthday = x.max_bd;

--Find the trainer, who has begun the training first.
WITH first_trainer AS (
	SELECT MIN(start_date) AS first
		FROM trainer 
)
SELECT t.tname, t.start_date
	FROM trainer t
	INNER JOIN first_trainer f
	ON t.start_date = f.first;

SELECT m.memname, t.start_date
	FROM member m
	INNER JOIN trainer t
	ON m.memname = t.tname
	WHERE t.start_date = (SELECT MIN(start_date) 	
								FROM trainer);

--Find average courses per area.
SELECT ROUND(AVG(tmp.numbers), 2) AS average_number_per_area
	FROM (SELECT COUNT(course_name) AS numbers
			FROM course
			WHERE area IS NOT NULL
			GROUP BY area) tmp;

WITH course_numbers AS (
	SELECT COUNT(course_name) AS numbers
		FROM course
		WHERE area IS NOT NULL
		GROUP BY area
)
SELECT ROUND(AVG(numbers), 2) AS average_number_per_area
	FROM course_numbers;

--Find members, which are enrolled in the highest number of courses.
WITH enrollment_numbers AS (
	SELECT memname, COUNT(*) AS course_number
		FROM enrollment
		GROUP BY memname
), max_enrollments AS (
	SELECT MAX(course_number) AS number
		FROM enrollment_numbers
)
	SELECT m.memname, m.gender, mx.number
		FROM member m
		INNER JOIN enrollment_numbers e
		ON m.memname = e.memname
		INNER JOIN max_enrollments mx
		ON e.course_number = mx.number;

--This query returns course's ID, name, the number of participants enrolled and the percentage of 
--total participants they account for, ordered by the number of participants in descending order.
SELECT c.course_id, c.course_name, COUNT(*) AS number_of_participants,
	(COUNT(*) * 100 / SUM(COUNT(*)) OVER()) AS percentage
	FROM enrollment e
	INNER JOIN course c
	ON c.course_id = e.course_id
	GROUP BY c.course_id
	ORDER BY COUNT(*) DESC;

--Identify the members with the highest number of enrollments, return their name, gender, 
--birthday, total number of enrollments and the maximum enrollment count among all members.
WITH tmp AS (
	SELECT m.memname, m.gender, m.birthday, COUNT(*) AS enrollment_number
		FROM member m
		INNER JOIN enrollment e
		ON m.memname = e.memname
		GROUP BY m.memname
)
	SELECT * FROM tmp
		WHERE tmp.enrollment_number = (SELECT MAX(enrollment_number)
											FROM tmp);

--This query determines the maximum number of enrollments for any individual member within each gender 
--group. It returns a distinct list of genders along with the highest enrollment count for each gender.
WITH tmp AS (
	SELECT m.gender, COUNT(*) AS enrollment_number
		FROM member m
		INNER JOIN enrollment e
		ON m.memname = e.memname
		GROUP BY m.memname
)
	SELECT * FROM tmp
		WHERE enrollment_number = (SELECT MAX(enrollment_number) FROM tmp
										WHERE gender = 'm')
	UNION
	SELECT * FROM tmp
		WHERE enrollment_number = (SELECT MAX(enrollment_number) FROM tmp
										WHERE gender = 'f');

WITH tmp AS (
	SELECT m.gender, COUNT(*), 
	MAX(COUNT(*)) OVER (PARTITION BY gender) AS maximum
	FROM enrollment e 
	INNER JOIN member m 
	ON m.memname=e.memname
	GROUP BY m.memname
)
	SELECT DISTINCT gender, maximum 
	FROM tmp;

]

]

--Create a view that displays: area, for each area the number of courses that is assigned to the area,
--the course names of the assigned courses concatenated into one string, nicely delimited,
--the percentage (of the total number of courses) that each area offers.
CREATE VIEW area_view AS (
	SELECT a.area, COUNT(c.*) AS number_of_courses, STRING_AGG(c.course_name, ','),
		COUNT(c.course_id) * 100.0 / SUM(COUNT(c.course_id)) OVER() AS percentage
	FROM area a
	INNER JOIN course c
	ON a.area = c.area
	GROUP BY a.area
)

--Create a view that displays all trainers and all information about them. The output table is to display 
--trainer name, birthday, age, gender, email, entryDate, licence and startTeach date.
CREATE VIEW trainer_info AS (
	SELECT t.tname, m.birthday, EXTRACT(YEAR FROM AGE(m.birthday)) AS age, 
		m.gender, m.email, m.entry_date, t.license, t.start_date
		FROM trainer t
		INNER JOIN member m
		ON m.memname = t.tname
)

--Display a list with parent names, the number of children they have in the club and the children's names.
SELECT p.memname, COUNT(p.*), STRING_AGG(c.memname, ',')
	FROM member p
	INNER JOIN member c
	ON c.parent = p.memname
	GROUP BY p.memname;
	
--Write a trigger which checks that a child cannot be registered in the club without parent: A child can only 
--be inserted if a parent is there. (If you have a check constraint that checks this, replace by a trigger.)
CREATE OR REPLACE FUNCTION fn_check_parent_of_child()
	RETURNS trigger
	LANGUAGE 'plpgsql'
	AS $BODY$
	BEGIN 
		IF EXTRACT(YEAR FROM AGE(NEW.birthday)) < 18 AND NEW.parent IS NULL THEN
			RAISE EXCEPTION 'child must have a parent!';
		END IF;
	END;
	$BODY$;

CREATE OR REPLACE TRIGGER tr_insert_child
	BEFORE INSERT
	ON member
	FOR EACH ROW
	EXECUTE FUNCTION fn_check_parent_of_child();

--How many children are boys and how many children are girls?
--Display gender, absolute numbers and percentage numbers
SELECT gender, COUNT(*) AS absolute_numbers,
	COUNT(*) * 100.0 / (SELECT COUNT(*) 
							FROM member
							WHERE EXTRACT(YEAR FROM AGE(birthday)) < 18)
	FROM member
	WHERE EXTRACT(YEAR FROM AGE(birthday)) < 18
	GROUP BY gender;

SELECT gender, COUNT(*) AS absolute_numbers, COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()
	FROM member
	WHERE EXTRACT(YEAR FROM AGE(birthday)) < 18
	GROUP BY gender;

WITH children_data AS (
	SELECT gender
		FROM member
		WHERE EXTRACT(YEAR FROM AGE(birthday)) < 18
) 
	SELECT cd.gender, COUNT(cd.*), count(cd.*) * 100.0 / SUM(COUNT(cd.*)) OVER()
		FROM children_data cd
		GROUP BY cd.gender;

--Display the parent name, parent gender and parent age and his / her number of children in the club.
SELECT p.memname, p.gender, EXTRACT(YEAR FROM AGE(p.birthday)) AS age, COUNT(*)
	FROM member p
	INNER JOIN member ch
	ON ch.parent = p.memname
	GROUP BY p.memname;

--In one result row to return: parent name, gender, age, name of one child, age of one child.
SELECT p.memname, p.gender, EXTRACT(YEAR FROM AGE(p.birthday)) AS parent_age, 
	ch.memname, EXTRACT(YEAR FROM AGE(ch.birthday)) AS child_age
	FROM member p
	INNER JOIN member ch
	ON ch.parent = p.memname
	ORDER BY p.memname;

--It would look much nicer, if we grouped by the parent name and collected the children names into one attribute.
SELECT p.memname, EXTRACT(YEAR FROM AGE(p.birthday)) AS age, p.gender, STRING_AGG(ch.memname, ',')
	FROM member p
	INNER JOIN member ch
	ON ch.parent = p.memname
	GROUP BY p.memname;
	
SELECT p.memname, EXTRACT(YEAR FROM AGE(p.birthday)) AS age, p.gender, 
	COUNT(*) AS number_of_children, STRING_AGG(ch.memname || ': ' || EXTRACT(YEAR FROM AGE(ch.birthday)), ', ')
	FROM member p
	INNER JOIN member ch
	ON ch.parent = p.memname
	GROUP BY p.memname;












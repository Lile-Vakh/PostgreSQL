--Returns all rows from those tables, where course and profs match.
SELECT * FROM examination
	INNER JOIN course
	USING (course_i_d,prof_i_d);

SELECT * FROM examination e
	INNER JOIN course c
	ON c.course_i_d = e.course_i_d
	AND c.prof_i_d = e.prof_i_d;

--Create view of courses, professors and students.
CREATE VIEW view_enroll AS (
	SELECT c.course_i_d, c.title, p.name AS professor, s.name, e.stud_i_d, s.semester
		FROM course c
		INNER JOIN professor p
		ON c.prof_i_d = p.prof_i_d
		INNER JOIN enrollment e
		ON c.course_i_d = e.course_i_d
		INNER JOIN student s
		ON s.stud_i_d = e.stud_i_d
);

--Create materialized view of courses, professors and students.
CREATE MATERIALIZED VIEW mat_view_enroll AS (
	SELECT c.course_i_d, c.title, p.name AS professor, s.name, e.stud_i_d, s.semester
		FROM course c
		INNER JOIN professor p
		ON c.prof_i_d = p.prof_i_d
		INNER JOIN enrollment e
		ON c.course_i_d = e.course_i_d
		INNER JOIN student s
		ON s.stud_i_d = e.stud_i_d
);

--Return a list that shows prof_id and prof_name of all professors and the number 
--of courses they teach, between 0 and n. 0 for those that do not teach at all.
SELECT p.prof_i_d, p.name, COUNT(c.course_i_d) AS number_of_courses
	FROM professor p
	LEFT JOIN course c
	ON c.prof_i_d = p.prof_i_d
	GROUP BY p.prof_i_d;

--What courses does course_id 5049 require as predeccessor courses? Display course_ids and course titles.
SELECT c.course_i_d, c.title
	FROM course c
	INNER JOIN requirement r
	ON c.course_i_d = r.predecessor
	WHERE r.successor = 5049;

--Which students are together in the course 5001? Show the student names.
SELECT s.name
	FROM student s
	INNER JOIN enrollment e
	ON s.stud_i_d = e.stud_i_d
	WHERE e.course_i_d = 5001;

--Are there students that took an exam but did not take a course at all?
SELECT s.name, e.stud_i_d 
	FROM examination e
	INNER JOIN student s
	ON s.stud_i_d = e.stud_i_d
	WHERE e.stud_i_d NOT IN (SELECT stud_i_d FROM enrollment);

--Student Carnap looks for an assistant that supervises his B.A. thesis. Display all assistants 
--that work for professors that teach at least one course Carnap is enrolled in. Display assistants 
--with ID and name and professorID and professor name the assistant works for.
SELECT a.assistant_i_d, a.name, p.prof_i_d, p.name
	FROM professor p
	INNER JOIN assistant a
	ON a.prof_i_d = p.prof_i_d
	INNER JOIN course c
	ON p.prof_i_d = c.prof_i_d
	INNER JOIN enrollment e
	ON e.course_i_d = c.course_i_d
	INNER JOIN student s
	ON s.stud_i_d = e.stud_i_d
	WHERE s.name = 'Carnap';

--Display the whole sequence of courses that are required, including semester 4.
--Display the courseIDs and the course titles of the sequence(s).
WITH RECURSIVE course_sequence AS (
	SELECT predecessor, successor,
		1 AS level,
		ARRAY[predecessor, successor] AS path
		FROM requirement 
	UNION ALL
	SELECT r.predecessor, r.successor, cs.level + 1, cs.path || r.successor
	FROM requirement r
	JOIN course_sequence cs
	ON r.predecessor = cs.successor
)
	SELECT c.course_i_d, c.title
		FROM course c
		JOIN (SELECT DISTINCT unnest(path) AS course_i_d
				FROM course_sequence
				WHERE array_length(path, 1) = 4

		) seq
		ON c.course_i_d = seq.course_i_d;

--Which professors do not teach? Write 3 syntactically different but semantically
--equivalent queries, using join, correlated subquery and uncorrelated subquery.
SELECT p.* 
	FROM professor p
	LEFT JOIN course c
	ON p.prof_i_d = c.prof_i_d
	WHERE c.prof_i_d IS NULL;

SELECT p.* FROM professor p
	WHERE NOT EXISTS (SELECT c.* FROM course c
						WHERE c.prof_i_d = p.prof_i_d);
	
SELECT * FROM professor
	WHERE prof_i_d NOT IN (SELECT prof_i_d FROM course);

--Display the teaching load (that is the contact hours) that each professor has. 
--Also display each professor’s percentage of the total teaching load (total contact hours).
--Write one query as subquery and another query with window function.
--Add the professor name to one of your output tables.
SELECT p.prof_i_d, p.name, SUM(COALESCE(c.contact_hours, 0)) AS teaching_load,
	SUM(COALESCE(c.contact_hours, 0))::FLOAT / (SELECT SUM(contact_hours) FROM course) * 100 AS percentage
	FROM professor p
	LEFT JOIN course c
	ON p.prof_i_d = c.prof_i_d
	GROUP BY p.prof_i_d;

SELECT p.prof_i_d, p.name, SUM(COALESCE(c.contact_hours, 0)) AS teaching_load,
	SUM(COALESCE(c.contact_hours, 0))::FLOAT / (SUM(SUM(c.contact_hours)) OVER()) * 100 AS percentage
	FROM professor p
	LEFT JOIN course c
	ON p.prof_i_d = c.prof_i_d
	GROUP BY p.prof_i_d;

--Which students scored less than average points in course 5001 (Foundation)? Display
--studentID, student name, semester, grade, average points and individual points
--Write the query once with subquery and once with CTE and once with window function.
SELECT s.stud_i_d, s.name, s.semester, e.grade, (SELECT AVG(points) 
													FROM examination e
													WHERE course_i_d = 5001), e.points
	FROM student s
	INNER JOIN examination e
	ON s.stud_i_d = e.stud_i_d
	WHERE e.course_i_d = 5001
	AND e.points < (SELECT AVG(points) 
						FROM examination e
						WHERE course_i_d = 5001);

WITH average_points AS (
	SELECT AVG(points) AS average
		FROM examination e
		WHERE course_i_d = 5001
)
	SELECT s.stud_i_d, s.name, s.semester, e.grade, a.average, e.points
		FROM student s
		INNER JOIN examination e
		ON s.stud_i_d = e.stud_i_d
		CROSS JOIN average_points a
		WHERE e.course_i_d = 5001
		AND e.points < a.average;

SELECT s.stud_i_d, s.name, s.semester, e.grade, 
	AVG(e.points) OVER (PARTITION BY e.course_i_d) AS average, e.points
	FROM student s
	INNER JOIN examination e
	ON s.stud_i_d = e.stud_i_d
	WHERE e.course_i_d = 5001
	AND e.points < (SELECT AVG(points) 
						FROM examination 
						WHERE course_i_d = 5001);

--Which students are enrolled in all 4-contact hour courses.
SELECT s.* FROM student s
	INNER JOIN enrollment e
	ON s.stud_i_d = e.stud_i_d
	INNER JOIN course c
	ON e.course_i_d = c.course_i_d
	WHERE c.contact_hours = 4
	GROUP BY s.stud_i_d
	HAVING COUNT(s.stud_i_d) = (SELECT COUNT(*) FROM course 
									WHERE contact_hours = 4);

--Create a table log_exam with the necessary columns (timestamp, current user, all old values, all new values). 
--Write a trigger which inserts a row into a log table whenever a row in the table examination is updated. 
--Exams and grades are final. No one should update / change a row in the examination table. 
CREATE TABLE log_exam (
	id SERIAL NOT NULL PRIMARY KEY,
	timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"current_user" CHARACTER VARYING(50) NOT NULL DEFAULT CURRENT_USER,
	all_old_values CHARACTER VARYING(255) NOT NULL,
	all_new_values CHARACTER VARYING(255) NOT NULL
);

CREATE OR REPLACE FUNCTION fn_log_update()
	RETURNS trigger
	LANGUAGE 'plpgsql'
	AS $BODY$
	BEGIN
		INSERT INTO log_exam(all_old_values, all_new_values)
		VALUES (ROW(OLD.*), ROW(NEW.*));
	END;
	$BODY$;

CREATE OR REPLACE TRIGGER examination_after_update
	AFTER UPDATE
	ON examination 
	FOR EACH ROW
	EXECUTE FUNCTION fn_log_update();

--Trigger, that generates student's email.
CREATE OR REPLACE FUNCTION generate_email()
	RETURNS trigger
	LANGUAGE 'plpgsql'
	AS $BODY$
	BEGIN
		NEW.student_email = NEW.name || '.' || NEW.semester || '@kiu.edu.ge';
		RETURN NEW;
	END;
	$BODY$;

CREATE OR REPLACE TRIGGER email_trigger
	BEFORE INSERT
	ON student
	FOR EACH ROW
	EXECUTE FUNCTION generate_email();

INSERT INTO student(stud_i_d, name, semester)
	VALUES(230, 'Lile', 7);











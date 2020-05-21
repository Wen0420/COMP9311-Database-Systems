-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(courseid, code)
as
select distinct Courses.id as courseid, Subjects.code as code 
from Courses 
join Course_staff on (Courses.id = Course_staff.course) 
join Subjects on (Courses.subject = Subjects.id) 
join Staff_roles on (Course_staff.role = Staff_roles.id)
where Subjects.code like 'LAWS%'
and Staff_roles.name = 'Course Tutor';

--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q2:
create or replace view Q2(unswid,name,class_num)
as 
select distinct Buildings.unswid as unswid, Buildings.name as name, count(Class_types.name) as class_num
from Buildings 
join Rooms on (Buildings.id = Rooms.building ) 
join Classes on (Rooms.id = Classes.room) 
join Class_types on (Classes.ctype = Class_types.id )
where Class_types.name = 'Lecture'
group by Buildings.unswid, Buildings.name
having count(Class_types.name) > 0;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q3:
create or replace view Q3(classid, course, room)
as 
select distinct Classes.id as classid, Classes.course as course, Classes.room as room 
from Students 
join People on (Students.id = People.id) 
join Course_enrolments on (Students.id = Course_enrolments.student) 
join Courses on (Course_enrolments.course = Courses.id) 
join Classes on (Courses.id = Classes.course)
join Rooms on (Classes.room = Rooms.id)
join Room_facilities on (Rooms.id = Room_facilities.room)
join Facilities on (Room_facilities.facility = Facilities.id)
where People.name = 'Craig Conlon'  
and Facilities.description = 'Television monitor'; 
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q4:
create or replace view Q4(unswid, name)
as 
select distinct People.unswid as unswid, People.name as name
from People
join Course_enrolments on (People.id = Course_enrolments.student)
join Courses on (Course_enrolments.course = Courses.id)
join Subjects on (Courses.subject = Subjects.id)
join Students on (Students.id = People.id)
where Students.stype = 'local'
and Course_enrolments.grade = 'CR'
and Subjects.code = 'COMP9021'

intersect

select distinct People.unswid as unswid, People.name as name
from People
join Course_enrolments on (People.id = Course_enrolments.student)
join Courses on (Course_enrolments.course = Courses.id)
join Subjects on (Courses.subject = Subjects.id)
join Students on (Students.id = People.id)
where Students.stype = 'local'
and Course_enrolments.grade = 'CR'
and Subjects.code = 'COMP9311';
--... SQL statements, possibly using other views/functions defined by you ...
;

--Q5:
create or replace view Q5_a(student, avgmark)
as
select distinct Course_enrolments.Student, avg(Course_enrolments.mark) as avgmark
from Course_enrolments 
where mark is not null
group by Course_enrolments.student;

create or replace view Q5(num_student)
as
select count(Q5_a.student) as num_student
from Q5_a
where Q5_a.avgmark > (
(select sum(Q5_a.avgmark) from Q5_a)/(select count(Q5_a.avgmark) from Q5_a)
);
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q6:
create or replace view Q6_a(semester, courseid, student_num)
as 
select Semesters.longname as semester, Courses.id as courseid, count(Student) as student_num
from Semesters join Courses on (Semesters.id = Courses.semester) join Course_enrolments on (Courses.id = Course_enrolments.course)
group by Semesters.longname, Courses.id
having count(Student) >= 10;

create or replace view Q6_b(semester, max_num)
as 
select Q6_a.semester, max(Q6_a.student_num) as max_num
from Q6_a
group by Q6_a.semester;

create or replace view Q6(semester, max_num_student)
as 
select Q6_b.semester, Q6_b.max_num as max_num_student
from Q6_b
where Q6_b.max_num = (
select min(Q6_b.max_num)
from Q6_b);

--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q7:
create or replace view Q7(course, avgmark, semester)
as
select Courses.id as Course, avg(mark) :: numeric(4,2) as avgmark, Semesters.name as semester
from Semesters 
join Courses on (Semesters.id = Courses.semester)
join Course_enrolments on (Courses.id = Course_enrolments.course)
where Course_enrolments.mark is not null 
and Semesters.term != 'Asem%'
and Semesters.year in ('2009', '2010')
group by Courses.id, Semesters.name
having count(Course_enrolments.mark) >= 20 and avg(mark) >80;


--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q8: 
create or replace view Q8_a(id)
as
select distinct People.unswid
from Streams 
join Stream_enrolments on (Streams.id = Stream_enrolments.stream)
join Program_enrolments on (Stream_enrolments.partOf = Program_enrolments.id)
join Students on (Program_enrolments.student = Students.id)
join People on (Students.id = People.id)
join Semesters on (Semesters.id = Program_enrolments.semester)
where Semesters.year = '2008'
and Semesters.term != 'Asem%'
and Students.stype = 'local'
and Streams.name = 'Law';

create or replace view Q8_b(id)
as
select distinct People.unswid
from Subjects
join Orgunits on (Subjects.offeredby = Orgunits.id)
join Courses on (Subjects.id = Courses.subject)
join Course_enrolments on (Courses.id = Course_enrolments.course)
join Students on (Course_enrolments.student = Students.id)
join People on (Students.id = People.id)
where Students.stype = 'local'
and Orgunits.name in ('Accounting', 'Economics');

create or replace view Q8(num)
as
select count(*) as num
from 
(select Q8_a.id from Q8_a
except
select Q8_b.id from Q8_b
) as A;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q9:
create or replace view Q9_a(subjectid, year, term)
as
select Subjects.id as subjectid, Semesters.year as year, Semesters.term as term
from Courses
join Semesters on (Courses.semester = Semesters.id)
join Subjects on (Courses.subject = Subjects.id)
where Subjects.code like 'COMP9%'
and Semesters.year between 2002 and 2013;

create or replace view Q9_b(year)
as
select distinct Semesters.year
from Semesters
where Semesters.year between 2002 and 2013;

create or replace view Q9_c(term)
as 
select distinct Semesters.term
from Semesters 
where Semesters.term = 'S1' or Semesters.term = 'S2';

create or replace view Q9_d(subjectid,term)
as 
select distinct a.subjectid, a.term
from Q9_a a
where not exists 
(select b.year from Q9_b b where not exists (select * from Q9_a c where c.subjectid = a.subjectid and c.term = a.term and c.year = b.year)
);

create or replace view Q9_e(subjectid)
as
select distinct a.subjectid
from Q9_d a
Where not exists 
(select b.term from Q9_c b where not exists (select *from Q9_d c where c.subjectid = a.subjectid and c.term = b.term)
);

create or replace view Q9_f(unswid, name, subjectid)
as
select distinct People.unswid as unswid, People.name as name, Subjects.id as subjectid
from Course_enrolments
join People on (Course_enrolments.student = People.id)
join Courses on (Course_enrolments.course = Courses.id)
join Subjects on (Courses.subject = Subjects.id)
join Q9_e on (Subjects.id = Q9_e.subjectid)
where Course_enrolments.grade in ('HD', 'DN');

create or replace view Q9(unswid, name)
as 
select distinct a.unswid, a.name
from Q9_f a
where not exists
(select b.subjectid from Q9_e b
where not exists 
(select * from Q9_f c where c.unswid = a.unswid and c.name = a.name and c.subjectid = b.subjectid)
);
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q10:
create or replace view Q10_a(unswid, longname)
as
select distinct Rooms.unswid as unswid, Rooms.longname as longname
from Rooms
join Room_types on (Rooms.rtype = Room_types.id)
where Room_types.description = 'Lecture Theatre';

create or replace view Q10_b(unswid, longname, classid)
as
select distinct Rooms.unswid as unswid, Rooms.longname as longname, Classes.id as classid
from Rooms
join Classes on (Rooms.id = Classes.room)
join Courses on (Classes.course = Courses.id)
join Semesters on (Courses.semester = Semesters.id)
join Room_types on (Rooms.rtype = Room_types.id)
Where Room_types.description = 'Lecture Theatre'
and Semesters.year = 2010
and Semesters.term = 'S2';

create or replace view Q10_c(unswid, longname, num)
as
select distinct unswid, longname, count(classid) as num
from Q10_b
group by unswid, longname
order by num desc;

create or replace view Q10_d(unswid, longname, num)
as
select distinct unswid, longname, 0 as num
from 
(select a.unswid, a.longname from Q10_a a
except select a.unswid, a.longname from Q10_a a, Q10_c c where a.unswid = c.unswid) as B;

create or replace view Q10(unswid, longname, num, rank)
as
select unswid, longname, num, rank() over (order by num desc) as rank 
from
(select * from Q10_c union select * from Q10_d) as Q10_cd;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q11:
create or replace view Q11_a(unswid, name)
as
select distinct People.unswid as unswid, People.name as name
from People
join Program_enrolments on (People.id = Program_enrolments.student)
join Program_degrees on (Program_enrolments.program = Program_degrees.program)
where Program_degrees.abbrev = 'BSc';

create or replace view Q11_b(unswid, name)
as
select distinct People.unswid as unswid, People.name as name
from Q11_a
join People on (Q11_a.unswid = People.unswid)
join Course_enrolments on (People.id = Course_enrolments.student)
join Courses on (Course_enrolments.course = Courses.id)
join Semesters on (Courses.semester = Semesters.id)
where Semesters.year = 2010
and Semesters.term = 'S2'
and Course_enrolments.mark >= 50;

create or replace view Q11_b1(unswid, name, program, avgmark)
as
select distinct People.unswid as unswid, People.name as name, Program_enrolments.program as program, avg(mark) as avgmark
from Q11_b
join People on (Q11_b.unswid = People.unswid)
join Course_enrolments on (People.id = Course_enrolments.student)
join Courses on (Course_enrolments.course = Courses.id)
join Program_enrolments on (Courses.semester = Program_enrolments.semester)
join Semesters on (Courses.semester = Semesters.id)
where Program_enrolments.student = Course_enrolments.student
and Semesters.year < 2011
and Course_enrolments.mark >= 50
group by People.unswid, People.name, Program_enrolments.program
having avg(mark) < 80;

create or replace view Q11_c(unswid,name)
as
select unswid, name from Q11_b 
except
select unswid, name
from Q11_b1;

create or replace view Q11_c1(unswid,name, UOC, sum)
as
select distinct People.unswid as unswid, People.name as name, Programs.UOC, sum(Subjects.UOC) as sum
from Q11_c 
join People on (Q11_c.unswid = People.unswid)
join Course_enrolments on (People.id = Course_enrolments.student)
join Courses on (Course_enrolments.course = Courses.id)
join Semesters on (Courses.semester = Semesters.id)
join Program_enrolments on (Courses.semester = Program_enrolments.semester)
join Subjects on (Courses.subject = Subjects.id)
join Programs on (Program_enrolments.program = Programs.id)
where Program_enrolments.student = Course_enrolments.student
and Semesters.year < 2011
and Course_enrolments.mark >= 50
group by People.unswid, People.name, Programs.UOC;

create or replace view Q11(unswid, name)
as
select unswid,name
from Q11_c1
where UOC <= sum;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q12:
create or replace view Q12_a(unswid, name, program, UOC, courseid)
as
select distinct People.unswid as unswid, People.name as name, Programs.name as program, Subjects.UOC, Courses.id as courseid
from People
join Course_enrolments on (People.id = Course_enrolments.student)
join Courses on (Course_enrolments.course = Courses.id)
join Subjects on (Courses.subject = Subjects.id)
join Program_enrolments on (Course_enrolments.student = Program_enrolments.student)
join Programs on (Program_enrolments.program = Programs.id)
join Program_degrees on (Program_enrolments.program = Program_degrees.program)
join Semesters on (Courses.semester = Semesters.id)
where Courses.semester = Program_enrolments.semester
and Program_degrees.abbrev = 'MSc'
and People.unswid / 10000 = 329
and Course_enrolments.mark is not null
and Course_enrolments.mark < 50;

create or replace view Q12_b(unswid, name, program, fail_UOC)
as
select distinct Q12_a.unswid, Q12_a.name, Q12_a.program, sum(Q12_a.UOC) as fail_UOC
from Q12_a
group by Q12_a.unswid, Q12_a.name, Q12_a.program;


create or replace view Q12_c(unswid, name, program, academic_standing)
as
select distinct Q12_b.unswid, Q12_b.name, Q12_b.program, 'Good' as academic_standing
from Q12_b
where fail_UOC < 12;

create or replace view Q12_d(unswid, name, program, academic_standing)
as
select distinct Q12_b.unswid, Q12_b.name, Q12_b.program, 'Probation' as academic_standing
from Q12_b
where fail_UOC between 12 and 18;

create or replace view Q12_e(unswid, name, program, academic_standing)
as
select distinct Q12_b.unswid, Q12_b.name, Q12_b.program, 'Exclusion' as academic_standing
from Q12_b
where fail_UOC > 18;

create or replace view Q12_f(unswid, name, program)
as
select distinct People.unswid as unswid, People.name as name, Programs.name as program
from People
join Course_enrolments on (People.id = Course_enrolments.student)
join Courses on (Course_enrolments.course = Courses.id)
join Subjects on (Courses.subject = Subjects.id)
join Program_enrolments on (Course_enrolments.student = Program_enrolments.student)
join Programs on (Program_enrolments.program = Programs.id)
join Program_degrees on (Program_enrolments.program = Program_degrees.program)
join Semesters on (Courses.semester = Semesters.id)
where Courses.semester = Program_enrolments.semester
and Program_degrees.abbrev = 'MSc'
and People.unswid / 10000 = 329
and Course_enrolments.mark is not null;

create or replace view Q12_g(unswid, name, program, academic_standing)
as
select distinct unswid, name, program, 'Good' as academic_standing
from 
((select * from Q12_f)
except 
(select unswid,name,program from Q12_a)
) as G;

create or replace view Q12(unswid, name, program, academic_standing)
as
select * from
(select * from Q12_c 
union 
select * from Q12_d
union
select * from Q12_e
union 
select * from Q12_g
) as W ;
--... SQL statements, possibly using other views/functions defined by you ...
;

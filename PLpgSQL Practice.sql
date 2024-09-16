-- CRUD operations

create database <name>;

drop database <name>;

create schema <name>;

drop schema <name> cascade;

create table if not exists <name> (
student_id int unique not null
);

insert into <table name> (column1 , column2)
values (value1, value2);

update <table name>
set column1 = value1
where condition;

delete from <table name>
where condition;

delete from <table name>;

truncate table <table name>;

alter table <name> 
add column <name>;

alter table <name>
rename column <name1> to <name2>;

alter table <name>
drop column <name>;

alter table <name1>
rename to <name2>;

drop table if exists <table name>;

-- Merge/Upsert

merge into target_table
using source_query
on merge_condition
when matched then update/delete/do nothing
when not matched then insert/do nothing;

merge into customers c
using temp_customer t on c.email=t.email
when matched then 
update set name = t.name
when not matched then 
insert(name,gender,email,address,dob)
values(t.name.t.gender,t.email,t.address,t.dob);

-- Views

create or replace view <name> as
<query>;

update <view name>
set column=value
where condtion;

-- Case

case when condition then result
when condition then result
else result
end;

-- PLpgSQL block

[<<label>>]
[declare declarations]
begin
	statements
end
[label];

do $$
<<block1>>
declare
	var1 integer := 0;
begin
	query;
	raise notice 'the number is %', var1;
end block1
$$;

variables
integer numeric boolean char varchar text date timestamp record

<constant name> constant data_type := value;
pi constant numeric := 3.1416;

select column1, column2
into var1, var2
from table_name
where condition;

DO $$
DECLARE
    v_name VARCHAR(50);
    v_salary     NUMERIC(11);
    v_gender     CHAR(1);
    v_job_role   VARCHAR(50);
BEGIN   
    SELECT name, monthly_salary, gender, job_role
    INTO v_name, v_salary, v_gender, v_job_role
    FROM professionals
    WHERE name = 'Bob Smith'; 
    RAISE NOTICE 'Name: %, Salary: %, Gender: %, DOB: %', v_name, v_salary, v_gender, v_job_role;
END
$$;

-- Conditional structure

if condition1 then statement1
elsif condition2 then statement2
else statement3
end if;

DO $$
DECLARE
    avg_month_salary NUMERIC(11,2);
BEGIN
    SELECT AVG(monthly_salary) INTO avg_month_salary FROM professionals;
    IF avg_month_salary > 15000 THEN
        RAISE NOTICE 'The average monthly salary of all professionals is high: % BDT', avg_month_salary;
    ELSIF avg_month_salary > 12000 THEN
        RAISE NOTICE 'The average monthly salary of all professionals is mid-tier: % BDT', avg_month_salary;
    ELSE
        RAISE NOTICE 'The average monthly salary of all professionals is low: % BDT', avg_month_salary;
    END IF;
END
$$;

-- Loops

do $$
declare
	counter integer := 0;
begin 
	loop
		counter := counter + 1;
		raise notice 'counter : %', counter;
		exit when counter := 10;
	end loop;
end
$$;

if counter := 10 then exit
end if;

-- While loop

do $$
declare
	counter := 1;
begin
	while counter <= 10 
	loop
		counter := counter + 1;
		raise notice 'counter : %', counter;
	end loop;
end
$$;

-- For loop

for loop_counter in [reverse] value1..value2 [by step]
loop
	statement;
end loop;

do $$
begin
	for loop_counter in 1..10 
	loop
		raise notice 'Counter : %',loop_counter;
	end loop;
end
$$;

do $$
begin 
	for loop_counter in reverse 10..1 by 2
	loop 
		raise notice 'Counter: %',loop_counter;
	end loop;
end
$$;

for record in query
loop
	statement;
end loop;

do $$
declare
	rec record;
begin
	for rec in 
		select * from professionals;
	loop
		raise notice 'Name: %, salary: %', rec.name, rec.salary;
	end loop;
end
$$;

-- Cursor

do $$
declare 
	emp_cur for select name, job from professionals;
	prof_rec record;
begin
	open emp_cur;
	loop
		fetch emp_cur into prof_rec;
		exit when not found;
		raise notice 'Name: %, Job: %',prof_rec.name, prof_rec.job;
	end loop;
	close emp_cur;
end
$$;

do $$
declare 
	prof_rec record;
begin
	for prof_rec in 
		select name, job from professionals;
	loop
		raise notice 'Name: %, Job: %',prof_rec.name, prof_rec.job;
	end loop;
end
$$;

-- Functions

create or replace function counter()
returns integer
language plpgsql
as
$$
declare
	counter integer;
begin
	select count(*) 
	into counter
	from professionals;
	return counter;
exception
	when others then
		raise notice 'Error occurred %', sqlerrm;
end;
$$;

select counter();

do $$
declare
	count integer;
begin
	count := counter();
	raise notice 'Count : %',count;
end
$$;

create or replace function get_name(
	in id integer;
	out name varchar;
)
language plpgsql;
as
$$
begin
	select prof_name
	into name
	from professionals
	where id = prof_id;
	if not found then 
		raise notice 'ID % not found.',id;
	end if;
end;
$$;

select name from get_name(101);

-- Exceptions

do $$
declare
	rec int;
	id int := 101;
begin
	select name
	into rec
	from professionals
	where id = prof_id;
	exception
		when no_data_found then
			raise notice 'ID % not found',id;
		when too_many_rows then
			raise notice 'Too many rows with id %',id;
		when others then
			raise exception 'Unexpected error occurred %',sqlerrm;
end;
$$;

-- Procedures

create or replace procedure salary()
language plpgsql
as
$$
begin
	update professionals
	set salary = salary * 1.10
	where job = 'Data analyst';
end;
$$;

call salary();

-- Dynamic SQL

create or replace procedure salary(
	salary_inc float;
	role text;
)
language plpgsql
as
$$
declare
	query text;
	table_name text;
begin
	table_name := 'professionals_' || to_char(now(), 'YYYYMMDD');
	execute 'drop table if exists ' || table_name;
	query := 'create table ' || table_name || ' as ' || 'select * from professionals';
	execute query;
	query := 'update professionals ' || 'set salary = salary * (1 + $1) ' || 'where role = $2';
	execute query using salary_inc, role;
	raise notice 'created table % and updated salaries for role %',table_name,role;
end
$$;

call salary(.20, 'Data analyst');


















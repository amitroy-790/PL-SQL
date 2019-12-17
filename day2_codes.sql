
----------------------------------------------------------------------------------
--EXCEPTION
--------------------

begin
	insert into salgrade values(6,10000,20000);
	insert into dept values (70, 'SOFTWARE TESTING DEPT', 'PUNE');
	update emp set sal=4000 where deptno=30;
	dbms_output.put_line(sql%rowcount ||'RECORDS UPDATED');
exception
when others then
rollback;
dbms_output.put_line('error info');
end;


----------------------------------------------------------------------------------

declare
	v_erow emp%rowtype; ---record type declaration
begin
	select * into v_erow from emp where empno=&eno;
	dbms_output.put_line(v_erow.ename||'   '||v_erow.sal||'   '||v_erow.job);
exception
	when no_data_found then
	rollback;
	dbms_output.put_line('error info');
end;

----------------------------------------------------------------------------------
-- Pre defined errors
--------------------------------------
declare
	v_ename emp.ename%type; ---record type declaration
begin
	select enaem into v_enaem from emp;
	dbms_output.put_line(v_erow.ename||'   '||v_erow.sal||'   '||v_erow.job);
exception
	when too_many_rows then
	rollback;
	dbms_output.put_line('error info');
	when others then
	null;
end;

----------------------------------------------------------------------------------
-- User defined errors
--------------------------------------
declare
	too_low_sal exception;
	v_sal emp.sal%type; ---record type declaration
begin
	select sal into v_sal from emp where empno=&eno;
	if v_sal between 500 and 2000 then
		raise too_low_sal;
	end if;
	dbms_output.put_line('Loan would be processed');
exception
	when too_low_sal then
	rollback;
	dbms_output.put_line('low salary');
	when no_data_found then
	rollback;
	dbms_output.put_line('wrong emp no');
	when others then
	rollback;
	dbms_output.put_line(sqlcode||' --- '||sqlerrm);
end;

----------------------------------------------------------------------------------
-- Not defined server errors
--------------------------------
declare
	large_value exception;
	pragma exception_init(large_value,-12899);
begin
	insert into dept values (70, 'SOFTWARE TESTING DEPT', 'PUNE');
exception
	when large_value then
	rollback;
	dbms_output.put_line('large value');
end;


----------------------------------------------------------------------------------
-- raise application errors
--------------------------------------
declare
	v_sal emp.sal%type; ---record type declaration
begin
	select max(sal) into v_sal from emp where job='MANAGER';
	if v_sal <5000 then
		raise_application_error(-20009,'Max sal is low for managers');
	end if;
end;


----------------------------------------------------------------------------------
-- Explicit curser
--------------------------------------
declare
	cursor c1 is select ename,sal,job from emp where sal>1500;
	v_cur c1%rowtype;
begin
	open c1;
	loop
		fetch c1 into v_cur;
		exit when c1%notfound;
		dbms_output.put_line(v_cur.ename||'  '||v_cur.job||'  '||v_cur.sal);
	end loop;
	close c1;	
end;

/*
begin
for i in c1 loop -- open and fetch the data
-- operation
end loop; -- implicit close
end
*/


----------------------------------------------------------------------------------
-- Explicit curser
--------------------------------------
declare
	cursor c1 is select empno,ename,sal,job from emp where sal>1000;
	v_etax number(7,2):= 0;
begin
	for i in c1 loop
		if i.sal between 100 and 2000 then v_etax:=100;
		elsif i.sal between 2000 and 3000 then v_etax:=200;
		else v_etax:=300;	
		end if;
		insert into emp_tax values(i.empno,i.ename,i.job,i.sal,v_etax);
	end loop;
end;



----------------------------------------------------------------------------------
-- Parameterized curser
--------------------------------------
declare
	cursor c1 (p_dno emp.deptno%type) is select empno,ename,deptno from emp where dept=p_dno;
	v_etax number(7,2):= 0;
begin
	for i in c1(&dno) loop
		dbms_output.put_line(i.empno||'  'i.ename||'  '||i.deptno);
	end loop;
end;



----------------------------------------------------------------------------------
-- For update curser  # lock the table for modification
-- 
--------------------------------------
declare
	cursor c1 is select empno,ename from emp_tax for update;
	v_etax number(7,2):= 0;
begin
	for i in c1(&dno) loop
		dbms_output.put_line(i.empno||'  'i.ename);
	end loop;
end;



----------------------------------------------------------------------------------
-- hr/hr
-- List department_id, department_name, manager_id, manager_name(first_name||' '||last_name)  
-- hr
--------------------------------------

declare
	type my_rec is record(a departments.department_id%type,b departments.department_name%type,c departments.manager_id%type,d employees.first_name%type,e employees.last_name%type);
	type my_tab is table of my_rec index by binary_integer;
	type manager_list is table of departments.manager_id%type index by binary_integer;
begin
	--select manager_id into manager_list from departments;
	for i in departments.first..departments.last loop
	
	select department_id,department_name,manager_id from departments and first_name,last_name from employees
	into my_tab(i).a,my_tab(i).b,my_tab(i).c,my_tab(i).d,my_tab(i).e where dept.manager_id=i.manager_id;
	end loop;
	select * from mytab;
end;

--****************************************************************



----------------------------------------------------------------------------------
-- create name procedures
--------------------------------------

create or replace procedure p1 is
	x number;
begin
	update emp set sal=sal+100;
	x:=sql%rowcount;
	dbms_output.put_line(x);
end;


----------------------------------------------------------------------------------
-- create name procedures with parameters
-----------------------------------------

create or replace procedure p2(p_dno in emp.deptno%type) is
	x number;
begin
	update emp set sal=sal*1.1 where deptno=p_dno;
	if sql%rowcount=0 then
		raise_application_error(-20189,'Invalid deptno');
		dbms_output.put_line(p_dno);
	end if;
end;



----------------------------------------------------------------------------------
-- create name procedures with in parameters
--------------------------------------------

create or replace procedure p2(p_dno in emp.deptno%type) is
	x number;
begin
	update emp set sal=sal*1.1 where deptno=p_dno;
	if sql%rowcount=0 then
		raise_application_error(-20189,'Invalid deptno');
		dbms_output.put_line(p_dno);
	end if;
end;



----------------------------------------------------------------------------------
-- create name procedures with in/out parameters
------------------------------------------------

create or replace procedure p3(p_dno in emp.deptno%type, p_mnsal out number, p_mxsal out number) is
begin
	select min(sal),max(sal) into p_mnsal,p_mxsal from emp where deptno=p_dno;
	if sql%rowcount=0 then
		raise_application_error(-20189,'Invalid deptno');
		dbms_output.put_line(p_dno);
	end if;
end;

----bind variables/host variables/session level
variable x number;
variable y number;
exec p3(10,:x,:y);
print :x;
print :y;
--------------------------------------------

-----named substitution------------
declare
v_x number;
v_y number;
begin
p3(p_mxsal=>v_y,p_mnsal=>v_x,p_dno=>20);
dbms_output.put_line(v_x||' '||v_y);
end;
--------------------------------------













----------------------------------------------------------------------------------
-- Explicit curser in procedure
--------------------------------------
create or replace procedure emp_tax_calc result.cache is
	cursor c1 is select empno,ename,sal,job from emp where sal>1000;
	v_etax number(7,2):= 0;
begin
	execute immediate 'truncate table emp_tax';
	for i in c1 loop
		if i.sal between 100 and 2000 then v_etax:=100;
		elsif i.sal between 2000 and 3000 then v_etax:=200;
		else v_etax:=300;	
		end if;
		insert into emp_tax values(i.empno,i.ename,i.job,i.sal,v_etax);
	end loop;
end;




----------------------------------------------------------------------------------
-- procedure with in & out parameter
--------------------------------------
create or replace procedure p4(p_x number, p_y in out number) is
begin
	p_y:=p_x+p_y;
end;

variable z number;
begin
:z:=20;
end;

-------
exec p4(10,:z);
-------
print :z;





----------------------------------------------------------------------------------
-- procedure with local subprogram
--------------------------------------
create or replace procedure pname is
x number;
--local subprogram
procedure px is 
begin
end px;

begin
	x:=10;
	px();
	x:=20;
	px();
end;



----------------------------------------------------------------------------------
-- ref curser
--------------------------------------
declare
	type curtype is ref cursor;
	c cutype;
	emp_rec emp%rowtype;
	flag varchar(10);
begin
	flag:='&X';
	if flag ='EMP' then
		open c for select * from emp;
	loop
		fetch c into emp_rec;
		exit when c%notfound;
	dbms_output.put_line(emp_rec.ename||'  '||emp_rec.job);
	end loop;
	close c;
	else
		dbms_output.put_line(flag||' is not correct');
	end if;
end;



----------------------------------------------------------------------------------
-- user defined functions
--------------------------------------
create or replace function esal(e_no in emp.empno%type) return number is
	t number;
begin
	select sal into t from emp where empno=e_no;
	return t;
exception
	when no_data_found then
	t:=0;
	return t;
end;



----------------------------------------------------------------------------------
-- user defined functions
--------------------------------------
create or replace function tax(esal number) return number is
	t number;
begin
	if esal<1500 then 
	t:=250;
	else
	t:=400;
	end if;
	return t;
end;

---------------------------------
select tax(4000) from dual;
select epmno,ename,sal,tax(sal) as etax from emp;
update emp set comm=tax(sal);
---------------------------------


----------------------------------------------------------------------------------
-- PACKAGE creation
--------------------------------------
create or replace package pack1 is
	g_var number:=0; -- public variable
	procedure p1(a in number);
	procedure p1(a in number, b out number);
end pack1;

create or replace package body pack1 is
l_var number:=0; -- local variable

procedure p1(a in number) is
v_x number;
begin
	l_var:=1;
	g_var:=a+l_var;
end p1;

procedure p1(a in number, b out number) is
v_x number;
begin
	b:=a+l_var+g_var;
end p1;

end pack1;




----------------------------------------------------------------------------------
-- PACKAGE creation -- without body.
--------------------------------------
create or replace package emp_dept is
	type myrec is record(a emp.empno%type,b emp.ename%type,c emp.job%type,d emp.sal%type,e dept.deptno%type,f dept.dname%type);
end emp_dept;
---------------------------------------
declare
x emp_dept.myrec;
begin
	select e.empno,e.ename,e.job,e.sal,d.deptno,d.dname into 
	x.a,x.b,x.c,x.d,x.e,x.f 
	from emp e join dept d on e.deptno=d.deptno and e.empno=7902;
	
	dbms_output.put_line(x.a||' | '||x.b||' | '||x.c||' | '||x.d||' | '||x.e||' | '||x.f);
end;



----------------------------------------------------------------------------------
-- package for exception to use in global level
--------------------------------------
create or replace package expconst is
missing_value exception;
pragma exception_init(missing_value,100);
end expconst;

---------
begin
exception
when expconst.missing_value then
null;
end


----------------------------------------------------------------------------------
-- SYNONYM
-- HR -> exec pluser.pack1.p1(10) 
-- HR -> p1(10) #after synonym
--------------------------------------
create synonym p1 for pluser.pack1.p1;
exec p1(10);


----------------------------------------------------------------------------------
-- TRIGGER
-- stop all dml operation on emp table every wednesday
-- statement level trigger
--------------------------------------
create or replace trigger emp_dml before delete on emp
declare
v_dy char(3):=to_char(sysdate,'Dy');
begin
	if v_dy='Wed' then
	raise_application_error(-20007,'Operattions not allowed today');
	end if;
end;


----------------------------------------------------------------------------------
-- row level TRIGGER
-- before update
--------------------------------------
create or replace trigger emp_up_sal before update of sal on emp
for each row
begin
	if :new.sal<:old.sal then
		--raise_application_error(-20007,'Operattions not allowed');
		:new.sal=:old.sal -- modify the input value to old value.
	end if;
end;


----------------------------------------------------------------------------------
-- replicate data /audit transaction /log
--------------------------------------
create table log_dept(l_dept number(3), l_dname varchar2(10), l_loc varchar2(10), l_operation varchar2(10));
--------------------------------------
create or replace trigger dept_audit after insert or update or delete on dept for each row
begin
	if inserting then
		insert into log_dept values(:new.deptno,:new.dname,:new.loc,'INSERT');
	elsif updating then
		insert into log_dept values(:old.deptno,:old.dname,:old.loc,'UPDATE');
	else
		insert into log_dept values(:old.deptno,:old.dname,:old.loc,'DELETE');
	end if;
end;



----------------------------------------------------------------------------------
-- view creation
--------------------------------------
create or replace view emp_vw as select * from emp; 
create or replace view emp_bonus as select empno,ename,sal*0.5 as ebonus from emp;



----------------------------------------------------------------------------------
-- trigger for view
--------------------------------------
create or replace trigger ins_dept_trg instead of insert on dept_vw for each row
declare
v_dno number;
begin
	select max(deptno) into v_dno from dept;
	insert into dept values(v_dno+10,:new.dname,:new.loc);
end;


----------------------------------------------------------------------------------
-- Index
--------------------------------------
explain plan for select * from employees;
select * from table (dbms_xplan.display());
explain plan for select * from employees where employee_id=102;
--------------------------------------
create index ix_dept on employees(department_id);


----------------------------------------------------------------------------------
-- Bulk collect
--------------------------------------
declare
	type dept_r is table of dept%rowtype;
	v_dr dept_r;
begin
	select * bulk collect into v_dr from dept;
	for i in v_dr.first..v_dr.last loop
	dbms_output.put_line(v_dr(i).dname);
end loop;
end;
	
















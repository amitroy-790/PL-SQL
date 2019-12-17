begin
dbms_output.put_line('hello');
end;

--------------------------------

declare
v_x number;
v_y number := 10;
v_z number;
begin
v_x:=&x;
v_z:= v_x + v_y;
dbms_output.put_line('The sum of '||v_x||', '||v_y||', is = '||v_z);
end;

-----------------------------------------------------

declare
	v_x number;
begin
	v_x:=&x;
	if v_x<10 then
		dbms_output.put_line('kid');
	elsif v_x>=10 and v_x<20 then
		dbms_output.put_line('Teen');
	else
		dbms_output.put_line('Adult');
	end if;
end;


-----------------------------------------------------


declare
	v_x number;
begin
	v_x:=&x;
	case
	when v_x<10 then dbms_output.put_line('kid');
	when v_x>=10 and v_x<20 then dbms_output.put_line('Teen');
	else dbms_output.put_line('Adult');
	end case;
end;


-----------------------------------------------------

declare
	v_x number;
begin
	v_x:=&x;
	loop
	dbms_output.put_line(v_x);
	v_x:=v_x/2;
	exit when (v_x/2)<10;
	end loop;
end;

------------------------------------------------------


begin
	for i in 10..20 loop
	dbms_output.put_line(i);
	end loop;
end;

------------------------------------------------------

begin
	insert into dept values(50,'QA','PUNE');
	update emp set sal=3500 where ename='SMITH';
	commit;
	delete from emp where sal<500;
end;

---------------------------------------------------------

begin
	insert into dept values(60,'BI','MUMBAI');
	dbms_output.put_line(sql%rowcount ||' RECORDS INSERTED');
	update emp set sal=3500 where deptno=10;
	if sql%rowcount>2 then
		dbms_output.put_line('Many records modified');
	end if;
	delete from emp where sal<500;
	if sql%notfound then
		dbms_output.put_line('No records deleted');
	end if;
end;

---------------------------------------------------------
declare
	v_ename varchar2(10);
	v_sal number(7,2);
begin
	select ename,sal into v_ename,v_sal from emp where empno=&eno;
	dbms_output.put_line(v_ename||'   '||v_sal);
end;


---------------------------------------------------------
declare
	v_min number(7,2);
	v_max number(7,2);
begin
	select MIN(sal),MAX(sal) into v_min,v_max from emp;
	dbms_output.put_line('Min sal:'||v_min||', Max sal:'||v_max);
end;


---------------------------------------------------------
declare
	v_ename emp.ename%type;
	v_sal emp.sal%type;
begin
	select ename,sal into v_ename,v_sal from emp where empno=&eno;
	dbms_output.put_line(v_ename||'   '||v_sal);
end;


---------------------------------------------------------
declare
	v_erow emp%rowtype; ---record type declaration
begin
	select * into v_erow from emp where empno=&eno;
	dbms_output.put_line(v_erow.ename||'   '||v_erow.sal||'   '||v_erow.job);
end;

--------------------------------------------------------------------------------

declare
	type my_rec is record(a emp.empno%type,b emp.ename%type,c emp.job%type,d emp.sal%type,e dept.deptno%type,f dept.dname%type); 
	v_myrec my_rec; ---record type declaration
begin
	v_myrec.a:=7902;
	select e.ename,e.job,e.sal,d.deptno,d.dname into 
	v_myrec.b,v_myrec.c,v_myrec.d,v_myrec.e,v_myrec.f 
	from emp e join dept d on e.deptno=d.deptno and e.empno=v_myrec.a;
	
	dbms_output.put_line(v_myrec.a||' | '||v_myrec.b||' | '||v_myrec.c||' | '||v_myrec.d||' | '||v_myrec.e||' | '||v_myrec.f);
end;


--------------------------------------------------------------------------------

declare
	type my_rec is record(a emp%rowtype,b dept%rowtype); 
	v_myrec my_rec; ---record type declaration
begin
	v_myrec.a.empno:=7902;
	select * into v_myrec.a from emp where empno=v_myrec.a.empno;
	select * into v_myrec.b from dept where deptno=v_myrec.a.deptno; 	
	dbms_output.put_line(v_myrec.a.empno||' | '||v_myrec.a.ename||' | '||v_myrec.a.job||' | '||v_myrec.a.sal||' | '||v_myrec.b.deptno||' | '||v_myrec.b.dname);
end;


--------------------------------------------------------------------------------

declare
	v_empno emp.empno%type;
	v_sal emp.sal%type;
begin
	v_empno:=&empno;
	select sal into v_sal from emp where empno=v_empno;
	if v_sal<1000 then
		dbms_output.put_line('LSAL '||v_sal);
	elsif v_sal>1000 and v_sal<3000 then
		dbms_output.put_line('MSAL '||v_sal);
	else
		dbms_output.put_line('HSAL '||v_sal);
	end if;
end;



--------------------------------------------------------------------------------

declare
	type my_tab is table of number(3) index by pls_integer; 
	v_mytab my_tab; ---record type declaration
begin
	for i in 1..10 loop
	v_mytab(i):=i*19;
	dbms_output.put_line(v_mytab(i));
	end loop;
end;



--------------------------------------------------------------------------------

declare
	type my_tab is table of number(3) index by pls_integer; 
	v_mytab my_tab; ---record type declaration
begin
	for i in 1..10 loop
	v_mytab(i):=i*19;
    end loop;
    dbms_output.put_line(v_mytab.count);
    for i in v_mytab.first..v_mytab.last loop
	dbms_output.put_line(v_mytab(i));
	end loop;
	v_mytab.delete(4);
	dbms_output.put_line(v_mytab.count);
    for i in v_mytab.first..v_mytab.last loop
	if v_mytab.exists(i) then
	dbms_output.put_line(v_mytab(i));
	end if;
	end loop;
end;



--------------------------------------------------------------------------------

declare
	type my_tab is table of dept%rowtype index by binary_integer; 
	v_mytab my_tab; ---record type declaration
	x number;
begin
	select count(*) into x from dept;
	for i in 1..x loop
		select * into v_mytab(i) from dept where deptno=i*10;
	end loop;
	for i in v_mytab.first..v_mytab.last loop
		dbms_output.put_line(v_mytab(i).deptno||'  '||v_mytab(i).dname);
	end loop;
end;



--------------------------------------------------------------------------------

declare
	type my_rec is record(a employees.first_name%type,b employees.last_name%type,c employees.phone_number%type);
	type my_tab is table of my_rec index by binary_integer; 
	v_mytab my_tab; ---record type declaration
begin
	for i in 100..149 loop
		select first_name,last_name,phone_number into v_mytab(i).a,v_mytab(i).b,v_mytab(i).c from employees where employee_id=i;
	end loop;
	for i in v_mytab.first..v_mytab.last loop
		dbms_output.put_line(v_mytab(i).a||' '||v_mytab(i).b||'  #  '||v_mytab(i).c);
	end loop;
end;





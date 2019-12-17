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
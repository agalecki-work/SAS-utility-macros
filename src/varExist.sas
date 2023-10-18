%macro VarExist(ds,var) / des = "M1: Check whether variable is defined in datasets";
	%local rc dsid result;
	%let dsid=%sysfunc(open(&ds));
	%if %sysfunc(varnum(&dsid,&var)) > 0 %then %do;
		%let result=1;
		%put NOTE: Var &var exists in &ds;
	%end;
	%else %do;
		%let result=0;
		%put NOTE: Var &var not exists in &ds;
	%end;
	%let rc=%sysfunc(close(&dsid));
	&result
%mend VarExist;

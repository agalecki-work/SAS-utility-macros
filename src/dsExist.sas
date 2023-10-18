%macro dsExist(ds) / des = "M1: Checks whether data set exists";
/** let x = dsExist(data) */
	%local result;
	%let result=%sysfunc(exist(&ds));

	%if &result = 1 %then %do;
		%put NOTE::: Data &ds exists;
	%end;
	%else %do;
		%let result=0;
		%put NOTE::: Data &ds does not exist;
	%end;
	&result
%mend dsExist;



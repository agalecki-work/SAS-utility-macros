%macro _nobsdata_(memname, libname = WORK, print = YES) / des = "M1: Creates _nobsdata_ containing number of observations";
/* --- NVAR NOBS --- */

proc sql ;
create table _nobsdata_ as
select libname, memname, nvar, nobs
from dictionary.tables
where libname="%upcase(&libname)" 
  %if %length(&memname) > 0 %then %do;
    and memname = "%upcase(&memname)"
   %end; 
;
quit ;
%if %upcase(&print) = YES %then %do;
proc print data = _nobsdata_;
run;
%end;
%mend _nobsdata_;

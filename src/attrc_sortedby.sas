%macro attrc_sortedby(member, libname = work) / des = "M1: Returns  sortedby attribute of the dataset ";
%local data DSID attrc anobs whstmt rc;
%let data = &libname..&member;
%let DSID = %sysfunc(open(&DATA., IS));
%if &DSID = 0 %then
%do;
 %put %sysfunc(sysmsg());
 %let attrc = ;
%goto mexit;
%end;

%let anobs = %sysfunc(attrn(&DSID, ANOBS));   /* specifies whether the engine knows the number of observations.*/
%let whstmt = %sysfunc(attrn(&DSID, WHSTMT)); /* specifies the active WHERE clauses.*/
%if &anobs=1 & &whstmt = 0 %then
%do;
%let attrc = %sysfunc(attrc(&DSID, SORTEDBY)); /* sorted by */
%end;
%mexit:
%if &DSID > 0 %then %let rc = %sysfunc(close(&DSID)); /* Close dsid */
&attrc
%mend attrc_sortedby;

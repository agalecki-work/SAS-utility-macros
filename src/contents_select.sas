%macro contents_select(data, 
           filter = %str(nlevels <=20 and type = 2), 
           include_vars =, exclude_vars =,
           print = N                     
) /des ="M1: Creates data contents with some additional variables " ;

/*
  Macro creates <contents_select> data containing data contents and some additional auxiliary vars: NLevels,  name_include, name_exclude, filter_include  
  Indicator variable <contents_select> contains putative list of variables to be used by PROC FREQ or other procedures
*/

%if %upcase(&filter) = _ALL_ %then %let filter = 1;


/* create contents */

/*--- process include  macro variables */
%let nword_include = %length(&include_vars);    /* String length returned*/

%if &nword_include > 0 %then %do; 
data include_select;
   set &data (obs=1); 
   keep &include_vars;
run;


proc contents data = include_select out = include_select_contents(keep = name) noprint;
run;

data include_select_contents;
  set include_select_contents;
  name_include =1;
run;

%if %upcase(&print) = Y %then %do;
Title "Contents_select macro: include_select_contents data";
proc print data = include_select_contents;
run;
%end;
%end;

/*--- process exclude  macro variables */
%let nword_exclude = %length(&exclude_vars);

%if &nword_exclude > 0 %then %do; 
data exclude_select;
   set &data (obs=1);
   keep &exclude_vars;
run;

proc contents data = exclude_select out = exclude_select_contents(keep = name) noprint;
run;

data exclude_select_contents;
  set exclude_select_contents;
  name_exclude = 1;
run;

%if %upcase(&print) = Y %then %do;
Title "Contents_select macro: exclude_select_contents data";
proc print data = exclude_select_contents;
run;
%end;


%end;

/* data contents and nlevels */
proc contents data =&data 
       out = contents_select_init(keep = libname memname name type length label varnum format nobs)
noprint;
run;

proc sort data = contents_select_init;
by name;
run;

/* create select_nlevels dataset */
ods select none;
ods output nlevels = select_nlevels;
proc freq  data= &data nlevels;
tables _all_;
run;
ods select all;

data select_nlevels;
 set select_nlevels (rename = (TableVar = name));
run;

proc sort data= select_nlevels;
 by name;
run;

/* Merge datasets with intermediate results */
data contents_select0;
  merge contents_select_init
        select_nlevels;
   by name;  
   name_include = .;
   name_exclude = .;
run;

%if &nword_include > 0 %then %do;        
 data contents_select0;
  update contents_select0
         include_select_contents;
        
 ;
 by name;
 run;
%end;

%if &nword_exclude > 0 %then %do;
data contents_select0;
  update contents_select0
          exclude_select_contents;
 ;
 by name;
run;
%end;

data contents_select;
  set contents_select0;
 %if %length(&filter) > 0 %then %do; 
 if (&filter) then filter_include=1; else filter_include=.;
 %end;
 %else %do;
  filter_include=0;
 %end;
 
 select;
  when(name_exclude = 1)                  contents_select = .;
  when(filter_include)                    contents_select = 1; 
  when (name_include =1)                  contents_select = 1;
  otherwise contents_select= .;
 end;
run;


proc sort data =contents_select;
by varnum;
run;

%mend contents_select; 

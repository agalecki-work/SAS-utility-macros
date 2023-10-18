
/***********************************************************************/
/*                                                                     */
/*  Filename: driver.inc                                               */
/*  Date:     Jauary 8, 1998                                           */
/*                                                                     */
/*  Purpose:  Driver macro                                             */
/*                                                                     */
/*  Nov. 2016 Renamed nvars macro variable to nvars_drvr                */
/***********************************************************************/


%macro driver(
  drive_dt=,
  vars=,
  use_mac=user_mac
) / des = "M1: Driver macro";

/* drive_dt - driver datsest e.g. dataset containing information
              on analysis points
   vars     - variable(s) containing information for use_mac
   use_mac  - user defined macro


*/

/* Count number of vars */

%let nvars_drvr=0;
%do %while(%scan(&vars,&nvars_drvr+1) ne );
%let nvars_drvr=%eval(&nvars_drvr+1);
%end;
%*put nvars_drvr &nvars_drvr;

data drive_dt;
  set &drive_dt;
run;

%let nlabels=0;
data _null_;
  set drive_dt nobs=driver_nobs;
  call symput('nlabels',driver_nobs);
  stop;
run;


/* Create macro variables */

/* Loop through all analyses points (all labels) */


%do anal_nr=1 %to &nlabels;
 %put ####   Analysis nr &anal_nr..   ##### ;

/* Extract macro variables listed in mvars */

data _null_;

  do anal_nr=&anal_nr;
     set drive_dt  point=anal_nr;

  %do i=1 %to &nvars_drvr;
    %let var=%scan(&vars,&i);
    /* put "&i" "&var"  &var ; */
    call symput("&var",trim(left(&var)));
  %end;
  stop;
  end;        /* end point */
run;

%&use_mac;

%end; /* anal_nr */
%mend driver;
